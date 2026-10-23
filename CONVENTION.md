# Code Style & Formatting Conventions

This document establishes the architecture, layout, whitespace, and typing standards for all GDScript files in **Just No Reason**.

---

## 1. File Skeleton & Structural Layout

Every script follows a strict top-to-bottom layout:

```gdscript
class_name MyClass extends Node
# OR: extends Node / @tool


# signals
signal my_signal()

# enums
enum MyEnum { A, B }

# consts
const SPEED := 10.0

# vars
@export var speed: float
var velocity: Vector3
@onready var sprite: Sprite2D = $Sprite2D


### fn

## virtual
#
func _ready():
	pass


## public
#
func perform_action() -> void:
	pass


## internal
#
func _check_input_mappings() -> void:
	pass

func _apply_visual_scale() -> void:
	pass


## helper
#
func calculate_speed() -> float:
	return SPEED


## signals
#
func _on_button_pressed() -> void:
	pass
```

---

## 2. Header Naming & Hierarchy

1. **Pluralized Section Headers (`# <category>`):**
   - Always pluralized: `# signals`, `# enums`, `# consts`, `# vars`.
2. **Top-Level Function Header (`### fn`):**
   - Denoted strictly with three hashes: `### fn`.
   - Preceded by **2 blank lines**.
   - Followed by **1 blank line** before the first function group subheader.
3. **Function Group Subheaders (`## <group>`):**
   - Denoted strictly with two hashes and an underlined `#` comment:
     ```gdscript
     ## helper
     #
     func my_helper() -> void:
     ```
   - Standard category names: `## virtual`, `## public`, `## internal`, `## helper`, `## signals`, `## SignalBus`.
   - Domain-specific subheaders are encouraged where logical (e.g. `## mouse / look`, `## stance & alignment`, `## weapons & combat`, `## ammo & reload`).

---

## 3. Whitespace & Spacing Rules

- **After Class/Extends Declarations:** Exactly **2 blank lines**.
- **Between Top Declaration Blocks:** Exactly **1 blank line** (e.g., between `# signals`, `# enums`, `# consts`, `# vars`).
- **Before `### fn`:** Exactly **2 blank lines**.
- **Before `## <group>` Subheaders:** Exactly **2 blank lines** (except when immediately following `### fn`, where 1 blank line is used).
- **Between Functions:** Exactly **1 blank line**.
- **Compact Pairings:** Intentional compact pairings (e.g., dual `@onready` lines or linked helper vars) are preserved.

---

## 4. Typing & Function Signatures

1. **Custom Functions Require Concrete Return Types:**
   - Every custom method, helper, internal function, and signal handler must declare an explicit return type (`-> void`, `-> bool`, `-> Vector3`, etc.) to eliminate ambiguous `-> Variant` editor tooltips.
2. **Engine & State Virtuals Exclude Return Types:**
   - Built-in engine virtual hooks (`_ready`, `_process`, `_physics_process`, `_input`, `_unhandled_input`) and `State` virtual overrides (`_enter`, `_exit`, `_state_input`, `_state_process`, `_state_physics_process`) **should not** declare `-> void`. This adheres strictly to Godot's virtual method dispatch standard.
3. **Parameter Typing:**
   - Always type parameters where known (e.g., `_delta: float`, `_event: InputEvent`).
4. **String Quotes:**
   - Always use single quotes (`'...'` and `&'...'`) for strings and `StringName` literals.

---

## 5. Logical Ordering & Feature Grouping

1. **Function Group Order:**
   - `## virtual` &rarr; `## public` &rarr; `## internal` / `## helper` &rarr; `## signals`.
2. **Feature & Domain Consistency:**
   - Keep orderings and groupings of related features logically consistent between files across the codebase.

---

## 6. Documentation & Comment Preservation

- **Zero-Deletion Rule:** Never delete comments, you can flag them for review but never assume deletion.

---

## 7. Upcoming Standards (Roadmap)

The following standards are pending final review and will be codified here once implemented:
1. **Standardize Variable Ordering within `# vars`:** Defining ordering rules (Type/Lifecycle order vs. Feature/Domain grouping).
2. **Underscore Naming Convention (`_`) for Variables:** Standardizing leading underscores for private/internal variables (mirroring internal functions).
