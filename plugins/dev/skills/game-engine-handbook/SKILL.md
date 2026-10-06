---
name: game-engine-handbook
description: Complete public-API reference for @leecheneler/game-engine — Lee's 2D TypeScript/WebGL2/Electron game engine. Everything needed to author a game against the engine as a black box - engine/scene/entity/component model, sprites, input, cameras, collision, physics, joints, audio, lighting, particles, post-processing, fs, packaging. Load when writing game code that uses the engine; this file is self-contained, so never read the engine's source or docs.
---

# Game Engine Handbook

The complete public API of `@leecheneler/game-engine` for authoring games. The engine is a **black box** — everything you need is here; don't read engine source or engine docs. Signatures were verified against the engine implementation, so if remembered or externally-documented API disagrees with this file, this file wins (see _APIs that don't exist_ at the end).

## What it is

- 2D game engine: TypeScript, strict, class-based (Unity/Godot-style), imperative core, zero UI-framework deps (React optional, overlay only).
- Rendering: WebGL2 — batched sprite renderer (one draw call per texture group), GPU point-sprite particles, lights/shadows, post-processing stack, frustum culling on by default.
- Runtime target: Electron desktop (Steam focus). Dev/build via the bundled `game-engine` CLI (Vite under the hood).
- Physics: built-in Box2D-style sequential-impulse solver — no external physics lib. Audio: Web Audio API with spatial pan/attenuation. Collision: spatial hash broad phase + SAT narrow phase.
- Package: `@leecheneler/game-engine`, ESM-only, published to GitHub Packages (`npm.pkg.github.com`).

## Import map (subpath exports — root does NOT re-export everything)

| Import                     | Contents                                                                                                                                                                                                                                                                                                                                           |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `@leecheneler/game-engine` | `Engine`, `Entity`, `Component`, `VERSION`, `EngineEvent`, `WIREFRAME_COLORS`; types: `IEngine`, `Scene`/`IScene`, `EngineConfig`, `SceneState`, `ComponentProps`, `MessageHandlers`, `Point`, `Vector2D`, `Surface`, `PhysicsConfig`, `AssetDescriptor`, `Renderer`, `Texture`, `AudioSystem`, `Input`, `Debug`/`DebugStats`, `IJointManager`     |
| `/components`              | `Transform2D`, `Camera2D`, `Sprite`, `Audio`, `PointLight`, `SpotLight`, `ShadowCaster`, `ShadowPointLight`, `ShadowSpotLight`, `RigidBody2D`, `BoxCollider`, `CircleCollider`, `PolygonCollider`, `ParticleEmitter`, joints: `Joint`, `DistanceJoint`, `SpringJoint`, `RevoluteJoint`, `PrismaticJoint`, `WeldJoint`, `RopeJoint` (+ Props types) |
| `/animation`               | `defineSpriteAnimations`, `ComputedSpriteAnimationData`                                                                                                                                                                                                                                                                                            |
| `/input`                   | `KeyCode`, `GAMEPAD_BUTTON_INDEX`, `GAMEPAD_AXIS_INDEX`, mouse/gamepad/input-mode types                                                                                                                                                                                                                                                            |
| `/collision`               | `collisionLayer`, `collisionMask`, `COLLISION_LAYER_ALL`, `COLLISION_LAYER_NONE`, `CollisionCallback`, raycast types                                                                                                                                                                                                                               |
| `/math`                    | vectors, matrices, geometry, `exponentialSmooth`, curves/gradients (`createLinearCurve`, `createConstantCurve`, `createLinearGradient`, `evaluateCurve`, `evaluateGradient`), shake, UV helpers                                                                                                                                                    |
| `/events`                  | `EngineEvent`, `IEventEmitter`, `EventHandler` types                                                                                                                                                                                                                                                                                               |
| `/post-effects`            | `PostProcessEffect`, `PostProcessStack`, `PostProcessContext`, effects: `Vignette`, `ChromaticAberration`, `FilmGrain`, `Pixelate`, `ColorGrading`, `GaussianBlur`, `Bloom`, `CRT`, `DepthFog`, `DepthOfField`                                                                                                                                     |
| `/fs`                      | `fs` API (Electron only)                                                                                                                                                                                                                                                                                                                           |

## Boot a game (canonical)

```typescript
import { Engine, Entity } from "@leecheneler/game-engine";
import {
  Transform2D,
  Sprite,
  Camera2D,
} from "@leecheneler/game-engine/components";
import { defineSpriteAnimations } from "@leecheneler/game-engine/animation";

const playerAnims = defineSpriteAnimations({
  textures: {
    idle: {
      src: "idle.png",
      frameWidth: 32,
      frameHeight: 32,
      textureWidth: 128,
      textureHeight: 32,
    },
  },
  animations: {
    idle: { texture: "idle", row: 0, frames: 4, fps: 8, loop: true },
  },
});

const engine = new Engine({
  container: "game-container",
  resolution: { width: 320, height: 180 },
  debug: false,
});
const scene = engine.createScene();

const player = new Entity();
player.addComponent(new Transform2D({ x: 160, y: 90 }));
player.addComponent(
  new Sprite({ animations: playerAnims, initialAnimation: "idle" }),
);
scene.addEntity(player);

const camera = new Entity();
camera.addComponent(new Transform2D({ x: 160, y: 90 }));
camera.addComponent(new Camera2D({ viewportWidth: 320, viewportHeight: 180 }));
scene.addEntity(camera);
engine.surface.camera = camera; // setter throws if the entity lacks Camera2D

await engine.switchTo(scene); // collect assets → preload → start scene
engine.start(); // begin RAF loop
```

- `EngineConfig` = `{ container: string /* DOM element ID, not element */, resolution: { width, height }, debug?: boolean }` — that's the whole config. Resolution is the virtual coordinate space; the engine letterboxes/pillarboxes to fit the container.
- HTML needs `<div id="game-container">`. Asset `src` paths resolve from Vite's `public/` dir (`"idle.png"` → `public/idle.png`).
- Without a bound camera the view matrix is identity and culling bounds are null — always bind a Camera2D entity for real games.
- Manual loading screen: `await scene.preload((loaded, total) => …); scene.start();` instead of letting `switchTo` do it.
- CLI: `"start": "game-engine dev"` (flags `--dev-tools`, `--window fullscreen`); `game-engine build` for packaging.

## Engine API

`engine.input` · `engine.events` · `engine.audio` · `engine.surface` (`canvas`, `camera` get/set, `screenToGame(clientX, clientY)`) · `engine.renderer` (`cullingEnabled` default true, `cullingMargin` default 0) · `engine.postProcess` · `engine.debug` (`enabled`, `config.*`, `stats.*`) · `engine.activeScene` · `engine.isRunning` · `engine.container` · `engine.resolution` · `createScene(): Scene` · `switchTo(scene): Promise<void>` · `start()` / `stop()` / `destroy()` · `onFrame(cb: (dt) => void)` / `offFrame(cb)`.

- Built-in events (constants on `EngineEvent`): `ge:scene:loading`, `ge:scene:ready`, `ge:scene:unloading` — payload `{ scene }`, emitted on `engine.events`.
- Keyboard input is ignored while an interactive DOM element (input/textarea) is focused. Window blur clears all input state.
- Master volume: `engine.audio.masterVolume = 0.5` (0–1). There is **no** `engine.masterVolume`.

## Scene API

`addEntity(entity): Entity` (throws if entity already in a scene) · `destroy(entity)` · `getEntityById(id)` · `getEntitiesByTag(tag): ReadonlySet<IEntity>` (a Set, not an array) · `preload(onProgress?)` · `start()` / `stop()` · `state: "created" | "preloading" | "ready" | "running" | "stopped"` · `engine` · `events` (scene-scoped emitter, cleared on scene stop) · `gravity: Vector2D` (readonly ref — mutate `.x`/`.y`; default `(0, 980)`) · `physics: PhysicsConfig` (readonly ref — mutate fields) · `darkness` (0–1, lighting) · `joints` · `collisions` (raycasts) · `collisionPairs` / `collisionCount` · `entityCount` · `interpolationAlpha`.

## Game loop

- RAF-driven. Per frame: dt → clear → component `update(dt)` (entity spawn order; component order within an entity **undefined**) → collision detection + callbacks → flush sprite batches → input end-frame.
- `dt` is **seconds** (~0.0167 @60fps), clamped to max **0.1s** (spiral-of-death protection). Always scale movement by dt.
- Fixed-timestep physics (when `scene.physics.timestepMode = "fixed"`) runs separate hooks (`updatePhysics`/`integrateForces`/`integratePosition`) on an accumulator at `fixedTimestep` intervals while `update()` still runs per frame; use `scene.interpolationAlpha` + `rigidBody.getInterpolatedPosition(alpha, out)` for render interpolation (Sprite does NOT interpolate automatically).
- Component `update` errors are caught and `console.error`-logged per entity — the loop never dies.
- Zero-allocation hot path: don't allocate objects inside `update()`.

## Entities & components

**Entity** is a container only. `new Entity()`; `id: number`, `isEnabled`, `tags: ReadonlySet<string>`, `scene`. Methods: `addTag`/`removeTag`/`hasTag`, `enable()`/`disable()` (disabled = no updates, still queryable), `addComponent<T>(instance): T` (**instance only** — no `(Class, props)` overload; throws if the component is already attached; multiple components of the same class allowed), `getComponent(Class): T | undefined` (first match), `getComponentsOfType(Class): T[]`, `hasComponent(Class)`, `removeComponent(Class)` (removes **all** of that class), `send(message, data?)`.

**Component** base: `class Component<TProps extends ComponentProps>`; constructor is `constructor(props?: TProps)` — **props only, no entity arg** (entity is attached later by `addComponent`). Accessors: `this.props` (readonly), `this.entity` (null until attached), `this.scene`, `this.engine`, `this.isEnabled`; per-component `enable()`/`disable()`.

**Lifecycle**: `onAttach()` (added to entity; entity may not be in a scene yet — grab sibling components here and fail fast) → `onAddToScene()` (entity added to scene; use for scene-system registration) → `onEnable()` (subscribe to events) → `update(dt)` per frame while component+entity enabled → `onDisable()` (unsubscribe) → `onDetach()` (release resources). Physics-only hooks: `updatePhysics(dt)`, `integrateForces(dt)`, `integratePosition(dt)`.

**Canonical custom component:**

```typescript
import { Component, type ComponentProps } from "@leecheneler/game-engine";
import { Transform2D } from "@leecheneler/game-engine/components";

interface HealthProps extends ComponentProps {
  max: number;
}

export class Health extends Component<HealthProps> {
  current: number;
  private transform: Transform2D | undefined;

  constructor(props: HealthProps) {
    super(props);
    this.current = props.max;
  }
  onAttach(): void {
    this.transform = this.entity?.getComponent(Transform2D);
    if (!this.transform) throw new Error("Health requires Transform2D");
  }
  onEnable(): void {
    this.engine?.events.on("game:reset", this.onReset);
  }
  onDisable(): void {
    this.engine?.events.off("game:reset", this.onReset);
  }
  private onReset = () => {
    this.current = this.props.max;
  }; // arrow fn = stable ref for off()

  messages = {
    "take-damage": ({ amount }: { amount: number }) => {
      this.current = Math.max(0, this.current - amount);
      if (this.current === 0)
        this.engine?.events.emit("entity:died", { entity: this.entity });
    },
  };
  update(dt: number): void {
    /* per-frame logic; dt in seconds */
  }
}
```

**Prefab pattern**: subclass `Entity`, compose in the constructor (`class EnemyPrefab extends Entity { constructor(x: number, y: number) { super(); this.addTag("enemy"); this.addComponent(new Transform2D({ x, y })); … } }`), then `scene.addEntity(new EnemyPrefab(100, 100))`.

**Assets**: components declare `get assets(): readonly AssetDescriptor[]` (`{ type: "texture" | "audio", src }`); the scene collects and preloads them (self-registration — no central manifest). **Entities added after `scene.preload()`/`switchTo` won't have their assets loaded** — preload again or load via texture cache manually.

**Pooling**: don't create/destroy entities inside `update` — disable + stash in an array, re-enable to spawn.

## Events vs messages

|           | Events                                            | Messages                      |
| --------- | ------------------------------------------------- | ----------------------------- |
| Direction | broadcast, 0..N subscribers                       | targeted at one entity        |
| Naming    | past tense (`player:died`)                        | imperative (`take-damage`)    |
| Use       | notifications, cross-cutting (UI/audio/analytics) | commands to a known recipient |

- EventEmitter API: `on<T>(event, handler)`, `off<T>(event, handler)` (same function reference required — store handlers as fields), `emit<T>(event, payload?)`, `clear()`. Duplicate registration is silently ignored; `emit` iterates in reverse so a handler may `off()` itself mid-emit.
- Two scopes: `engine.events` persists across scenes; `scene.events` is cleared when the scene stops.
- Messages: `entity.send<T>(message, data?)` → delivered to all enabled components on that entity with a matching handler in their `messages: MessageHandlers` field. Handler errors caught+logged. No return value; **no group send** — iterate `scene.getEntitiesByTag(...)` yourself.

## Transforms & coordinates

- **Y-down, origin top-left** (web convention): +X right, +Y down. Units = world-space pixels of the virtual resolution (center of 320×180 is (160, 90)).
- `Transform2D` fields (mutable public, defaults): `x: 0`, `y: 0`, `z: 0`, `rotation: 0` (**radians, clockwise positive**), `scaleX: 1`, `scaleY: 1`.
- **No parent/child hierarchy** — positions are world-space (hierarchy may come later).
- `z` = draw order (higher = in front), sorted per frame; changing `z` mid-frame affects the next frame. Patterns: fixed layers (bg −100 / game 0 / UI 1000) or `transform.z = transform.y` for top-down pseudo-3D. **Z lives on Transform2D, not Sprite.**
- `getWorldMatrix(): Float32Array` — column-major 4×4, pre-allocated stable reference overwritten each call; copy if you need to keep it.

## Sprites & animation

Sheets are row-organized: one animation per row, frame 0 leftmost. Define animation data once at module scope; it's shared across sprites.

```typescript
const anims = defineSpriteAnimations({
  textures: {
    main: {
      src: "player.png",
      frameWidth: 32,
      frameHeight: 32,
      textureWidth: 128,
      textureHeight: 96,
    }, // all required
  },
  animations: {
    idle: { texture: "main", row: 0, frames: 4, fps: 8, loop: true },
    attack: {
      texture: "main",
      row: 1,
      frames: 6,
      fps: 15,
      loop: false,
      next: "idle",
    }, // next = auto-chain
  },
});
```

- Static sprite = 1-frame animation (`frames: 1, fps: 0`). There is no texture-only Sprite API.
- `SpriteProps`: `animations` (required), `initialAnimation?`, `width?`/`height?` (default frame size), `origin?` (`{x,y}` 0–1, default `{0.5,0.5}`, also the rotation pivot), `tint?` (`{r,g,b,a}` default white; multiplied with texture; `a<1` = transparency), `flipX?`/`flipY?` (render-only mirror — does NOT affect colliders; prefer over negative scale), `offsetX?`/`offsetY?` (local offset from entity position, rotated with entity).
- Playback: `sprite.play(name, onEnd?: (completed: boolean) => void)` (`completed` false = interrupted), `stop()` (freeze on frame), `currentAnimation`, `isPlaying`, `isPlayingAnimation(name)`. `tint`/`flipX`/`flipY` mutable at runtime.
- Only `play()` on state change (track state yourself), not every frame. `next` is static — for state-dependent transitions use the `onEnd` callback.

## Input (polling — check in `update()` via `this.engine?.input`)

Semantics per frame: `isPressed` = first frame down only; `isHeld` = every frame while down (incl. pressed frame); `isReleased` = frame it goes up only.

```typescript
input.isPressed(KeyCode.Space); input.isHeld(KeyCode.KeyW); input.isReleased(KeyCode.KeyE);
input.isMousePressed("left"); input.isMouseHeld("right"); input.isMouseReleased("middle");
input.mouseX; input.mouseY;              // viewport coords (NOT window px, NOT world)
input.getMouseState();                   // { x, y, buttons: { left, middle, right } }
input.getMouseWheelDelta();              // { deltaX, deltaY }, per-frame, resets each frame
input.isGamepadConnected(index?);        // index defaults to 0
input.isGamepadPressed("a"); input.isGamepadHeld("b"); input.isGamepadReleased("x");
// buttons: a b x y lb rb lt rt back start ls rs dpad-up|down|left|right (Xbox layout)
input.getGamepadAxis("left-x");          // -1..1, deadzone applied; axes: left-x/left-y/right-x/right-y
input.setDeadzone(0.2); input.getDeadzone();          // default 0.1
input.getInputMode();                    // "kbm" | "gamepad" — auto-switches on use
input.on("input-mode-change", (mode) => {}); input.on("gamepad-connected", (i) => {});
input.setCursorVisible(false);
```

- `KeyCode` values are `KeyboardEvent.code` strings (physical position, layout-independent), named exactly like the DOM codes: `KeyCode.KeyA`…`KeyZ`, `Digit0`–`9`, `ArrowUp/Down/Left/Right`, sided modifiers (`ShiftLeft`, `ControlRight`, `AltLeft`, `MetaLeft`), `Space`, `Enter`, `Escape`, `Tab`, `F1`–`F12`, `Numpad0`–`9`, `NumpadAdd`… Raw code strings also work: `input.isPressed("BracketLeft")`.
- Mouse → world is two steps: `engine.surface.screenToGame(clientX, clientY)` (screen px → viewport, handles letterboxing, `null` outside viewport) then `camera.viewportToWorld(x, y)`. `input.mouseX/Y` are already viewport coords, so from input you only need `viewportToWorld`. There is **no** `input.mouseWorldPosition`.

## Cameras (surface/camera split)

An entity with `Transform2D` + `Camera2D` bound via `engine.surface.camera = cameraEntity`. Move the camera by mutating its Transform2D.

`Camera2D` props (all mutable at runtime): `viewportWidth`/`viewportHeight` (required, >0), `zoom` (default 1; 2 = zoomed in), `rotation` (radians CW), `follow` (`IEntity | undefined`), `followSmoothing` (default 1 = instant; **higher = faster catch-up**, ~0.1 = floaty; frame-rate independent via `exponentialSmooth`; 0 behaves as 1), `followOffsetX/Y` (px, applied before smoothing), `bounds` (`{minX,minY,maxX,maxY}` clamp; if world < viewport it centers).

```typescript
camera.shake({ intensity: 10, duration: 0.5, seed? });  // decays; re-calling resets, doesn't stack
camera.isShaking; camera.positionX; camera.positionY;   // actual position (lags under smoothing)
camera.getViewBounds();          // { left, right, top, bottom, width, height } world coords
camera.viewportToWorld(vx, vy);  // → { x, y }; accounts for position/zoom/rotation
camera.worldToViewport(wx, wy);
```

## Collision detection

Detection only — response needs `RigidBody2D`. Broad phase: spatial hash (64px cells); narrow phase: OBB/circle/SAT.

- Colliders: `BoxCollider({ width, height })` (rotates with transform), `CircleCollider({ radius })` (rotation-invariant), `PolygonCollider({ vertices })` (≥3 local-space verts, normalizes to CCW; **concave outlines are supported natively** — pass the full star/L/arrow outline and it is decomposed into convex pieces once at construction; tests/picks/raycasts run against the pieces, callbacks fire once for the whole collider; outline must be simple/non-self-intersecting; `collider.isConvex` tells you which case). Do NOT split a concave shape into several `PolygonCollider`s on one entity — the collision manager keys items by `(entityId, colliderType)` so only the first of each type registers.
- Shared props: `offsetX`/`offsetY` (rotate with entity), `tag?` (string surfaced in callbacks), `layer` (bitmask, default 1), `mask` (default `COLLISION_LAYER_ALL`), `onCollideStart` (first overlap frame), `onCollide` (every overlapping frame), `onCollideEnd` (separation). Callback: `(otherEntity, otherCollider, otherTag) => void`.
- There is **no sensor/isSensor flag** — a collider without a RigidBody2D is effectively a trigger (callbacks, no physical response).
- Layers: A↔B collide iff `(A.layer & B.mask) && (B.layer & A.mask)`. `collisionLayer(0)` → 1, `collisionLayer(0,1)` → 3; `collisionMask` is an alias. Pattern: `const LAYER_PLAYER = 0; … layer: collisionLayer(LAYER_PLAYER), mask: collisionMask(LAYER_ENEMY, LAYER_PICKUP)`.
- **Hard cap: MAX_PAIRS = 512 collision pairs** — excess contacts silently dropped.

Raycasts on `scene.collisions`:

```typescript
scene.collisions.linecastFirst(fromX, fromY, toX, toY, layerMask?)                    // → hit | null
scene.collisions.raycastFirst(originX, originY, dirX, dirY, maxDistance, layerMask?)  // dir must be normalized
scene.collisions.linecast(fromX, fromY, toX, toY, callback, layerMask?)               // all hits closest-first
scene.collisions.raycast(originX, originY, dirX, dirY, maxDistance, callback, layerMask?)
// callback: return true to stop early
// hit: { item: { entity, collider }, distance, pointX, pointY, normalX, normalY }
```

`*First` methods are zero-allocation — the hit object is reused internally, don't retain it. Prefer `*First` + masks + bounded distance.

## Physics

Per step: gravity → broad phase → SAT → warm start (0.8) → iterative velocity solve (contacts + joints) → integrate → split-impulse position correction → sleep. Two-tier sleep needs low velocity **and** a support path to static geometry — floating clusters never sleep.

`RigidBody2D` requires `Transform2D`; add a collider for collision response.

| Prop                 | Default                 | Notes                                                                                               |
| -------------------- | ----------------------- | --------------------------------------------------------------------------------------------------- |
| `bodyType`           | `"dynamic"`             | `"static"` immovable · `"kinematic"` velocity-only, ignores gravity/forces, pushes but isn't pushed |
| `mass`               | `1`                     | min 0.001                                                                                           |
| `gravityScale`       | `1`                     | 0 floats, negative rises                                                                            |
| `drag`               | `0`                     | `v *= (1 - drag*dt)`                                                                                |
| `friction`           | `0.1`                   | for `slide`; 0 = ice                                                                                |
| `velocityX/Y`        | `0`                     | px/s, mutable accessors                                                                             |
| `responseType`       | `"bounce"`              | `"bounce"` reflect · `"slide"` keep tangent · `"stop"` zero velocity                                |
| `bounciness`         | `0.5`                   | 0–1, bounce only                                                                                    |
| `angularVelocity`    | `0`                     | rad/s                                                                                               |
| `angularDrag`        | inherits `drag`         | >1 helps bodies settle on planks                                                                    |
| `momentOfInertia`    | auto from collider+mass | explicit value never recomputed                                                                     |
| `fixedRotation`      | `false`                 | lock rotation                                                                                       |
| `ccd`                | `false`                 | speculative CCD — opt-in, fast movers (bullets) only; >10,000 px/s can still rarely tunnel          |
| `onPhysicsCollision` | —                       | per-collision response override, see below                                                          |

Methods: `setVelocity(x, y)` · `applyForce(fx, fy)` (accumulates over frame; continuous — thrust/wind) · `applyImpulse(ix, iy)` (instant — jump/explosion) · `applyTorque(t)` · `applyAngularImpulse(i)` · `getInterpolatedPosition(alpha, out)`. Force/impulse are dynamic-only.

`onPhysicsCollision(data) => "bounce" | "slide" | "stop" | undefined` — return overrides the body's response for that collision. `data`: `{ otherEntity, otherCollider, otherRigidBody, normalX, normalY, penetration, contactX, contactY }`. Normal points from this entity toward the other: `normalY < -0.5` ⇒ floor hit (canonical grounded check), `> 0.5` ⇒ ceiling.

`scene.physics` fields: `timestepMode: "variable"` (default) `| "fixed"` (deterministic accumulator, max 8 steps/frame), `fixedTimestep` (1/60), `collisionIterations` (8; 16 for stacks), `constraintIterations` (4; 8–16 for chains), `substeps` (4 — the main stability lever).

Platformer pattern: grounded flag reset each update, set in `onPhysicsCollision` when `normalY < -0.5`, return `"slide"`; horizontal via `applyForce`, jump via `applyImpulse(0, -jumpImpulse)` when grounded; typical body `{ gravityScale: 2, drag: 5, friction: 0, responseType: "slide" }`.

## Joints

Both entities need `Transform2D` + `RigidBody2D`. Joint is a component on entity A referencing B: common props `connectedEntity: IEntity` (required), `anchorA`/`anchorB: Vector2D` (local offsets, default `{0,0}`).

| Joint            | Constrains                         | Key props (defaults)                                                                                                                                        |
| ---------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DistanceJoint`  | exact distance (rigid rod)         | `distance` (auto from initial gap), `correctionFactor` (1), `damping` (0), `allowSlack` (false; true = rope)                                                |
| `SpringJoint`    | elastic (Hooke)                    | `restLength` (auto when omitted), `springConstant` (100), `dampingRatio` (0.5, fraction of critical)                                                        |
| `RevoluteJoint`  | shared pivot, free rotation        | `enableMotor` (false), `motorSpeed` (rad/s), `maxMotorTorque` (0), `enableLimit` (false), `lowerAngle`/`upperAngle`, `damping` (0, unclamped, 2–10 typical) |
| `PrismaticJoint` | single-axis slide, locked rotation | `axis` (`{1,0}` local on A), `enableLimit`, `lowerTranslation`/`upperTranslation` (px), `enableMotor`, `motorSpeed` (px/s), `maxMotorForce`                 |
| `WeldJoint`      | position + rotation locked         | `frequencyHz` (0 = rigid; >0 = soft spring-damper), `dampingRatio` (0.7)                                                                                    |
| `RopeJoint`      | max distance, slack allowed        | `maxLength` (auto), `correctionFactor` (1), `damping` (0) — sugar for DistanceJoint `allowSlack: true`                                                      |

Stability: keep `springConstant/mass < 3600`; fixed timestep for consistent joints; raise `constraintIterations` for chains; long distance-joint chains lose energy (position correction is dissipative) — single direct joint for pendulums; give chain links distinct collision layers so they don't collide with each other. **No breakable joints.** Patterns: chain = N links each DistanceJoint to previous (`damping: 0.5`); cloth = SpringJoint grid + diagonal shear springs (rest `spacing*√2`); trampoline = dynamic surface (`gravityScale: 0`) sprung to static anchor (`springConstant: 8000, dampingRatio: 0.15`). Debug: `engine.debug.enabled = true; engine.debug.config.joints = true`.

## Audio

Pipeline: mp3/wav/ogg/webm → AudioCache (decode once) → `Audio` component → optional StereoPanner (spatial) → per-sound gain → master gain. Clips preload with the scene.

```typescript
entity.addComponent(
  new Audio({ clips: { jump: "/sounds/jump.mp3" }, volume: 0.8 }),
);
```

Props: `clips` (name → path, required), `volume` (1), `loop` (false), `playbackRate` (1, clamped 0.1–4), `spatial` (false), `referenceDistance` (100, min 1), `maxDistance` (500, ≥ referenceDistance), `autoPlay` (clip name; **throws at construction if not in `clips`**).

Methods (`play` returns a numeric sound id): `play(clipName, { volume?, loop?, playbackRate?, spatial? }?): number` · `stop(id)` · `stopClip(name)` · `stopAll()` · `pause(id)` / `resume(id)` · `isPlaying(id)` · `isClipPlaying(name)` · `activeSoundCount`.

- Every `play()` is an independent instance (polyphony) — guard one-shots with `isClipPlaying`.
- Spatial: listener = camera; 100% inside `referenceDistance`, linear falloff to 0 at `maxDistance`, stereo pan by horizontal offset. Runtime setters affect new sounds; active sounds re-position each frame. `debug: true` draws orange maxDistance circles.
- Variation: randomize `playbackRate` 0.9–1.1 or pick among clips. Music: `autoPlay` + `loop: true` on a dedicated entity; `stopClip` on scene change.

## Lighting

Enable with `scene.darkness` (0 = fully lit, lights invisible; 1 = pitch black). Lights render to an offscreen lightmap (additive between lights, multiplied with scene); off-screen lights auto-culled. All lights need `Transform2D`; all props mutable at runtime.

- `PointLight`: `radius` (px, required), `intensity` (1; >1 overbright), `color` (`{r,g,b}` 0–1), `softness` (0.5; 0 hard → 1 soft).
- `SpotLight` adds: `angle` (outer cone, radians, required), `innerAngle` (default `angle*0.5`), `offsetRotation` (0, relative to entity rotation — the cone rotates with the entity).
- `ShadowCaster`: no props; needs `Transform2D`+`Sprite`; pixels with alpha > 0.5 block light (binary shadows).
- `ShadowPointLight`/`ShadowSpotLight` add: `shadowSoftness` (0.5; up to ~4), `shadowResolution` (256, clamped 64–512 — 512 hero light, 128 static, 64 distant), `penumbraScale` (0.02; ~1–2 for contact shadows), `shadowScale` (1000 = full-length; 1–4 = short stylized; 0 = none).

Patterns: cheap PointLights for fill + one ShadowPointLight on the player; flicker = randomize `intensity`/`radius` in a controller `update`; mouse-aim spotlight: `light.offsetRotation = Math.atan2(dy, dx) - transform.rotation`.

## Particles

`new ParticleEmitter({ config, emitting? })` on an entity with `Transform2D`. GPU point sprites; always a procedural 64×64 soft-circle white texture tinted by color — **no custom particle texture option**. Config (only `maxParticles` + `lifetime` required):

```typescript
{
  maxParticles: 250,                        // pool; recycles oldest; ≥ rate × maxLifetime
  lifetime: { min: 0.4, max: 0.8 },         // seconds
  emissionMode: { type: "continuous", rate: 140 }          // default continuous @10/s
              | { type: "burst", count: 25, interval?: 2 },// omit interval = one-shot
  emitterShape: { type: "point" } | { type: "circle", radius, edge? }
              | { type: "rectangle", width, height, edge? } | { type: "line", length, angle /*deg*/ },
  velocity: { speed: { min, max }, angle: { min, max } },   // deg: 0=right, 90=up, 270=down
  size:  { initial: 10, sizeOverLifetime?: { keys: [{ time /*0-1*/, value }] } },   // lerped multiplier
  color: { initial: { r, g, b }, colorOverLifetime?: { keys: [{ time, color }] } },
  alpha: { initial: 1, alphaOverLifetime?: Curve },
  physics: { gravity?: { x, y }, drag? /*0-1*/ },
  blendMode: "additive" /*default: fire/sparks/glow*/ | "alpha" /*smoke/rain/dust*/,
  cullingRadius?, maxCullingRadius?,        // offscreen emitters skip sim+render
}
```

Runtime: `emitter.emitting = bool`; `emitter.burst(count?)` (works while not emitting); `emitter.activeParticleCount`. All of an emitter's particles share the entity's `transform.z` — separate emitters for separate depths. Batched by blend mode — mixing additive+alpha at similar z adds draw calls. One-shot explosion: burst emitter with `emitting: false` → `.burst(n)` → destroy entity after max lifetime.

## Post-processing

`engine.postProcess` — ping-pong buffers, zero overhead when empty. Applied in add order; recommended: Bloom → Blur → ColorGrading → Vignette → FilmGrain/ChromaticAberration → CRT last.

API: `addEffect(e)` · `insertEffect(i, e)` · `removeEffect(e): boolean` · `reorderEffect(e, i)` · `getEffect(EffectClass)` · `effectPassCount` · `drawCallCount`. Per-effect: `enabled` (true), `resolution` (1.0; 0–1 downscale for cheap blur/bloom).

Built-ins (property = default): `VignetteEffect` `intensity=.3 radius=.8 softness=.4` · `ChromaticAberrationEffect` `intensity=.005` · `FilmGrainEffect` `intensity=.1 grainSize=1` · `PixelateEffect` `pixelSize=4` · `ColorGradingEffect` `brightness=0 contrast=1 saturation=1 hueShift=0` (radians) · `GaussianBlurEffect` `radius=2` · `BloomEffect` `threshold=.8 softThreshold=.5 intensity=1 scatter=.7 levels=5` · `CRTEffect` `scanlineIntensity=.3 scanlineFrequency=2 curvature=.02 colorBleed=.003 vignetteIntensity=.2 brightness=1.1` · `DepthFogEffect` `color=[.5,.5,.5] near=0 far=1 density=1` (auto-enables depth buffer; higher z = more fogged) · `DepthOfFieldEffect`.

Custom effect: extend `PostProcessEffect` with a `fragmentShader` defining `vec4 effect(vec4 color, vec2 uv)` and `override getUniforms()` returning your uniform values. Auto-injected uniforms: `u_sceneColor`, `u_resolution`, `u_time`, and `u_depthTexture` when `override readonly requiresDepth = true`. Multi-pass: override `apply(input, output, ctx)` with `ctx.acquireFramebuffer(this.resolution)` / `ctx.renderPass(shaderSrc, inputTex, targetFbo, uniforms)`; release in `dispose(ctx)`.

## Shape/primitive rendering — the constraint to remember

- **All shape rendering is wireframe/outline-only** (`gl.LINES`): `renderer.renderLine(x0,y0,x1,y1,color)`, `renderBox(…corners…, color)`, `renderCircle(x,y,r,color)` (32 segments), `renderCone(x,y,r,dir,angle,color)`. These are the debug-draw internals; game visuals normally go through Sprite components.
- `renderPoint(x, y, color)` is the sole filled primitive — a fixed ~4px debug quad.
- **There is no filled-geometry API** (no fillRect/fillCircle) and **no built-in 1×1 white texture** — to draw a solid colored rectangle, ship a small white texture asset and tint a Sprite with it.
- Colors are `{r,g,b,a}` floats 0–1; `WIREFRAME_COLORS` presets: GREEN sprite bounds, CYAN collision, ORANGE audio, PINK origins, YELLOW lights, MAGENTA emitters, RED joints.

## File system (Electron only)

`import { fs } from "@leecheneler/game-engine/fs"` — throws in plain browser/Node/SSR (needs the `window.gameEngineFs` IPC bridge).

```typescript
fs.read(path, opts?): Promise<string>       fs.write(path, content, opts?): Promise<void>
fs.readJSON<T>(path, opts?): Promise<T>     fs.writeJSON(path, data, opts?): Promise<void>
fs.exists(path, opts?): Promise<boolean>    fs.delete(path, opts?): Promise<void>
fs.list(path, opts?): Promise<string[]>     // filenames, not full paths
// opts: { base?: "userData" | "cwd" }, default "userData"
```

`userData` = Electron app-data dir (saves/settings, persists across updates); `cwd` = project dir, dev tooling only. Paths must be relative and sandboxed — absolute paths, `..`, and null bytes throw. Methods throw on failure.

## Platform & packaging

- `game-engine dev` = Vite dev server + Electron window with hot reload. `game-engine build` outputs `release/macos/MyGame.app` | `release/windows/MyGame/MyGame.exe` | `release/linux/MyGame/` — **host OS only**; cross-platform needs per-OS CI runners.
- macOS builds are ad-hoc signed; downloaded unsigned releases need `xattr -cr <app>.app`. Windows/Linux: portable dirs, no installer.
- Steam Deck: Linux build works as-is (or Windows-via-Proton). Chromium renderer sandbox is deliberately disabled (Steam Deck user-namespace restrictions hang Electron; trusted first-party code only).

## Project structure & React UI

Structure follows need — start small, grow a directory only when its trigger hits. Files are kebab-case.

Small game (the starting point):

```
src/
  main.ts          # engine boot + (optional) React mount — nothing else
  game.ts          # scene assembly: camera, entities, wiring
  components/      # custom Component subclasses, one per file (health.ts, player-controller.ts)
  animations/      # defineSpriteAnimations data, shared at module scope (player-animations.ts)
public/
  sprites/  audio/  fonts/   # assets — src paths resolve from here
```

Growth steps (each with its trigger):

```
src/
  config/
    constants.ts   # trigger: 5+ tuning values. SCREAMING_SNAKE (MOVE_SPEED, JUMP_IMPULSE)
    layers.ts      # as soon as you have 2+ collision layers — define layer indices + masks ONCE here
  scenes/          # trigger: 2+ scenes
    index.ts       # registry: Record<SceneName, (engine) => Scene> + a loadScene(engine, name) helper
    level-one.ts   # one file per scene: create{Name}Scene(engine): Scene
  entities/        # trigger: 3+ entity types
    player.ts      # factory create{Name}(scene, x, y): Entity — or an Entity subclass prefab
  data/            # static game data: waves, dialogue, item tables (plain TS/JSON modules)
  systems/         # trigger: logic spanning scenes — save/load (via /fs), score, achievements
  ui/              # React overlay components, when UI outgrows a single App.tsx
```

Per-directory rules:

- `main.ts` stays minimal: `new Engine(...)`, initial `switchTo`, `engine.start()`, React mount. No game logic.
- `scenes/*`: a scene factory builds and returns a `Scene` — create camera entity, bind `engine.surface.camera`, call entity factories, `return scene`. Scenes don't import each other; switching goes through the registry.
- `entities/*`: factories compose components onto a `new Entity()` (or subclass `Entity` as a prefab). Entities don't know about scenes beyond the `scene` arg they're added to.
- `components/*`: one component per file; components communicate via sibling `getComponent`, `entity.send` messages, and engine/scene events — never by importing other game files' state. Compose many small components over one monolith.
- `animations/*`: define once, share everywhere — the computed data is reusable across sprites.
- `config/layers.ts` is the single source of collision-layer truth: `export const LAYER_PLAYER = 0;` plus prebuilt masks with `collisionLayer`/`collisionMask`.
- Naming: `create{Name}Scene(engine): Scene`, `create{Name}(scene, x, y): Entity`, `{name}Animations`, `{Component}Props`, SCREAMING_SNAKE constants.
- Nest by area/feature (`scenes/dungeon/`, `entities/enemies/`) only when flat lists get unwieldy.
- React overlay: two containers — `<div id="game-container">` (canvas) + `<div id="root">` with `pointer-events: none` (individual elements re-enable via `pointerEvents: "auto"`). Mount `createRoot(root).render(<App engine={engine} />)` after engine setup. Bridge = events only:

```tsx
useEffect(() => {
  const h = (e: { health: number }) => setHealth(e.health);
  engine.events.on("player:damaged", h);
  return () => engine.events.off("player:damaged", h);
}, []);
```

React never touches the game loop; the game never imports React.

## Performance

- Batching is automatic per texture+blend mode — use atlases, minimize unique textures; batch breaks are the main draw-call cost. Culling: `engine.renderer.cullingEnabled` / `cullingMargin`.
- Collision: layers/masks so only relevant pairs are tested; MAX_PAIRS = 512; CCD bullets-only.
- Zero allocation in `update`; pool entities; unsubscribe handlers.
- Lights: fewer/larger; shadow lights sparingly at the lowest acceptable `shadowResolution`.
- Stats on `engine.debug.stats`: `visibleSprites`, `culledSprites`, `drawCalls`, `visiblePointLights`, `culledPointLights`, `visibleSpotLights`, `visibleShadowPointLights`, `shadowCasterCount`, `activeParticles`, `visibleEmitters`, `culledEmitters`, physics counters. Debug draw toggles on `engine.debug.config` (`pointLights`, `spotLights`, `shadowCasters`, `particleEmitters`, `joints`, …).

## APIs that don't exist — never write these

Plausible-looking APIs that are NOT in the engine (they appear in stale docs/examples elsewhere — don't reproduce them):

1. `new Sprite({ textures: ["x.png"], frameWidth, … })`, `sprite.setTexture()`, `sprite.setAnimation({...})` — sprites always take `animations` from `defineSpriteAnimations` + `play()`.
2. `scene.spawn().with(Class, props)` builder — use `new Entity()` + `addComponent(new Class(props))` + `scene.addEntity`.
3. `constructor(entity, props)` component constructors — props only; the entity is attached by `addComponent`.
4. `addComponent(Class, props)` overload — instance only.
5. `engine.cullingEnabled` / `engine.masterVolume` — actually `engine.renderer.cullingEnabled` / `engine.audio.masterVolume`.
6. `input.mouseWorldPosition` — use `input.mouseX/Y` + `camera.viewportToWorld`.
7. `engine.send("group", "msg", …)` group-send — only `entity.send` exists; iterate `getEntitiesByTag` for groups.
8. `followSmoothing` as "lower = faster" — inverted; higher = faster catch-up, 1 = instant.
9. Root-package imports of `createLinearCurve`/`collisionLayer`/`Transform2D`/`KeyCode` — they live in `/math`, `/collision`, `/components`, `/input` respectively (see the import map).
10. `fs.writeJSON("userData", path, data)` — wrong arg order; it's `fs.writeJSON(path, data, { base: "userData" })`.
11. Filled-shape rendering (`fillRect`/`fillCircle`), custom particle textures, sensor/`isSensor` collider flags, breakable joints, transform parenting — none exist (see the relevant sections for the substitutes).
