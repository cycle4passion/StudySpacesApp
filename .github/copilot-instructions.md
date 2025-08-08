<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# StudySpaces Flutter App Instructions

This is a Flutter application for discovering study spaces at Cornell University libraries. The app features:

- A list view of Cornell Study Spaces with hero animations
- Detailed views for each space
- JSON data structure for space information
- Material Design UI components
- Hero animations for smooth transitions between list and detail views

When working on this project:

- Use Material Design components for consistent UI
- Implement proper hero animations for image transitions
- Follow Flutter best practices for state management
- Use proper JSON serialization for data models
- always check the utils folder for utility functions for existing function that can help with common tasks like is the space open, color management, space data handling, and text formatting.
- withOpacity method is deprecated, always use recommended withValues(alpha: value) instead.
- when errors are accumulating and you suggest reverting via git, first give option to revert code instead and abort.

If you wish to run flutter analyze and rerun the test environment use chrome not ios please.
