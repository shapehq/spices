# ``Spices``

Spices makes it straightforward to create in-app debug menus by generating native UI from Swift.

## Overview

Spices generates native in-app debug menus from Swift code using the ``Spice`` property wrapper and ``SpiceStore`` protocol and stores settings in `UserDefaults`.

We built Spices at [Shape](https://shape.dk) (becoming [Framna](https://framna.com)) to provide a frictionless API for quickly creating these menus. Common use cases include environment switching, resetting state, and enabling features during development.

See [the README on GitHub](https://github.com/shapehq/spices) for reference documentation.

![iPhone screen recording showing an in-app debug menu.](example.gif)

## Topics

### Essentials

- ``Spice``
- ``SpiceStore``

### Present the In-App Debug Menu

> Note: The in-app debug menu may contain sensitive information. Ensure it's only accessible in debug and beta builds by excluding the menu's presentation code from release builds using conditional compilation.

- ``SpiceEditor``
- ``SpiceEditorViewController``
- ``SpicesWindow``
- ``SwiftUICore/View/presentSpiceEditorOnShake(editing:)``

### Customization

- ``SpicesTitleProvider``
