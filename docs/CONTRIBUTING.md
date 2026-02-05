# Contributing to Neural Aegis

Thank you for your interest in contributing to Neural Aegis! This guide will help you get started.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn
- Keep discussions on-topic

## Ways to Contribute

### 1. Report Bugs
Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) to report issues.

### 2. Suggest Features
Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) to propose new features.

### 3. Add New Tools
Use the [tool addition template](.github/ISSUE_TEMPLATE/tool_addition.md) and see [DEVELOPMENT.md](DEVELOPMENT.md#adding-a-new-tool).

### 4. Add New Themes
Edit `data/themes.json` with your theme and submit a PR.

### 5. Improve Documentation
Help make guides clearer, fix typos, add examples.

### 6. Code Contributions
Fix bugs, implement features, improve performance.

## Development Setup

### Prerequisites
- Godot 4.2 or higher
- Git
- (Optional) Docker for containerized development

### Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/neural-aegis.git
   cd neural-aegis
   ```
3. Create a branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Open in Godot and make your changes
5. Test your changes thoroughly
6. Commit and push:
   ```bash
   git add .
   git commit -m "Add: your feature description"
   git push origin feature/your-feature-name
   ```
7. Open a Pull Request

## Code Style Guidelines

### GDScript Style

Follow these conventions for consistency:

#### Naming Conventions
```gdscript
# Classes: PascalCase
class_name MyClassName

# Variables and functions: snake_case
var my_variable: int = 0
func my_function():
    pass

# Constants: UPPER_SNAKE_CASE
const MAX_SPEED: float = 100.0

# Private functions: prefix with underscore
func _private_helper():
    pass

# Signals: snake_case
signal item_collected
```

#### Type Hints
Always use type hints:
```gdscript
# Good
var health: int = 100
func damage(amount: int) -> void:
    pass

# Avoid
var health = 100
func damage(amount):
    pass
```

#### Comments
```gdscript
## Documentation comment for classes/functions
## Visible in editor help
func public_function():
    pass

# Regular comment for implementation details
func _internal_logic():
    # Explain complex logic
    var result = complex_calculation()
```

#### Code Organization
```gdscript
# 1. Class declaration
class_name ToolName
extends Tool

# 2. Signals
signal tool_activated

# 3. Exports
@export var tool_power: int = 10

# 4. Public variables
var is_active: bool = false

# 5. Private variables (prefixed with _)
var _internal_state: int = 0

# 6. Lifecycle methods
func _ready():
    pass

func _process(delta):
    pass

# 7. Public methods
func activate():
    pass

# 8. Private methods
func _calculate():
    pass
```

## Testing Your Changes

### Manual Testing Checklist

Before submitting a PR, verify:

- [ ] Game runs without errors (check console output)
- [ ] New features work as expected
- [ ] Existing features still work
- [ ] All three themes work correctly
- [ ] Tools respect cooldowns and resource costs
- [ ] Logs display correctly with color coding
- [ ] UI updates properly (score, resources, threats)
- [ ] No visual glitches or layout issues

### Tool-Specific Testing

If you added/modified a tool:

- [ ] Tool button appears in palette
- [ ] Tool tooltip displays correctly
- [ ] Tool respects cooldown timer
- [ ] Tool consumes correct resources
- [ ] Tool provides visual feedback
- [ ] Tool updates status bar
- [ ] Tool description matches functionality

### Theme Testing

If you added/modified a theme:

- [ ] Theme appears in dropdown
- [ ] All required keys present in JSON
- [ ] Terminology makes sense
- [ ] Logs display themed terms correctly
- [ ] Theme switching works smoothly

## Pull Request Process

### PR Title Format
```
Add: New feature description
Fix: Bug description
Update: What was updated
Docs: Documentation changes
```

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Testing
How have you tested this?

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed the code
- [ ] Commented complex logic
- [ ] Updated documentation
- [ ] Tested manually
- [ ] No new warnings/errors
```

### Review Process

1. Maintainers review your PR
2. Address any requested changes
3. Once approved, PR will be merged
4. Your contribution will be credited!

## Adding a New Tool (Quick Guide)

See [DEVELOPMENT.md](DEVELOPMENT.md#adding-a-new-tool) for detailed steps.

Quick checklist:
1. Create `tools/YourTool.gd` extending `Tool`
2. Implement `_ready()` and `use_tool()`
3. Add button to `scenes/ToolPalette.tscn`
4. Test thoroughly
5. Document in PR

## Adding a New Theme (Quick Guide)

1. Edit `data/themes.json`
2. Add new theme object with all keys:
   ```json
   "your_theme": {
     "name": "Display Name",
     "threat_actor": "singular",
     "threat_actor_plural": "plural",
     "secondary_threat": "singular",
     "secondary_threat_plural": "plural",
     "resource": "singular",
     "resource_plural": "plural",
     "location": "singular",
     "location_plural": "plural",
     "defensive_action": "action name",
     "honeypot": "decoy name",
     "honeypot_bait": "bait name",
     "trace_action": "trace name",
     "normal_entity": "singular",
     "normal_entity_plural": "plural"
   }
   ```
3. Test theme switching
4. Submit PR

## Documentation Contributions

Improvements welcome for:
- Fixing typos
- Clarifying instructions
- Adding examples
- Improving formatting
- Translating to other languages (future)

## Community Guidelines

### Be Respectful
- Treat everyone with respect
- Accept constructive criticism
- Give constructive feedback

### Be Patient
- Remember everyone is learning
- Help newcomers get started
- Explain your reasoning

### Stay On Topic
- Keep discussions focused
- Use appropriate channels
- Search before asking

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Use bug report template
- **Features**: Use feature request template
- **Security**: Email maintainers directly (don't open public issue)

## Recognition

Contributors are recognized in:
- README.md contributors section
- Release notes
- In-game credits (future feature)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Thank You!

Your contributions make Neural Aegis better for everyone. Whether you're fixing a typo, adding a feature, or helping other contributors, your effort is appreciated! 🎮🔒
