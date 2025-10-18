# Contributing to Nvibe

Thank you for your interest in contributing to Nvibe! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
- Use the GitHub issue tracker to report bugs or suggest features
- Include as much detail as possible (Neovim version, OS, error messages, etc.)
- Check existing issues before creating new ones
- Use appropriate labels when creating issues

### Suggesting Features
- Open a discussion or issue to propose new features
- Explain the use case and how it would benefit users
- Consider the plugin's focus on AI-powered coding environments

### Code Contributions
- Fork the repository and create a feature branch
- Follow the existing code style and conventions
- Add tests for new functionality
- Update documentation as needed
- Submit a pull request with a clear description

## 🛠️ Development Setup

### Prerequisites
- Neovim 0.7+
- NvChad (for testing)
- Lua development environment
- Git

### Local Development
1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/nvibe.git
   cd nvibe
   ```

2. Install dependencies:
   ```bash
   make install-deps
   ```

3. Run tests:
   ```bash
   make test
   ```

4. Run linter:
   ```bash
   make lint
   ```

### Testing
- All new features should include tests
- Run the test suite before submitting PRs
- Test with different Neovim configurations
- Verify compatibility with NvChad

## 📝 Code Style

### Lua Conventions
- Use 2 spaces for indentation
- Use descriptive variable names (avoid `success`, `err`)
- Add comprehensive comments for complex functions
- Follow the existing function documentation format

### Documentation
- Update README.md for user-facing changes
- Update CHANGELOG.md for all changes
- Add/update function documentation in init.lua
- Update CUSTOMIZATION.md for new configuration options

### Commit Messages
Use conventional commit format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `refactor:` for code refactoring
- `test:` for test additions/changes

Example:
```
feat: add minimap integration for better layout management

- Add toggle_minimap configuration option
- Implement minimap detection and toggling
- Update documentation with new feature
```

## 🎯 Areas for Contribution

### High Priority
- **Testing**: Improve test coverage and add integration tests
- **Documentation**: Enhance user guides and API documentation
- **Error Handling**: Improve error messages and recovery
- **Performance**: Optimize layout restoration and terminal creation

### Medium Priority
- **Configuration**: Add more customization options
- **Terminal Support**: Support for additional terminal plugins
- **Layout Options**: More flexible layout arrangements
- **Plugin Integration**: Better integration with other Neovim plugins

### Low Priority
- **UI Enhancements**: Visual improvements and status indicators
- **Advanced Features**: Complex layout management features
- **Platform Support**: Better cross-platform compatibility

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment**:
   - Operating System and version
   - Neovim version (`nvim --version`)
   - NvChad version/commit
   - Nvibe version/commit

2. **Reproduction Steps**:
   - Clear steps to reproduce the issue
   - Expected vs actual behavior
   - Screenshots or error messages

3. **Configuration**:
   - Your Nvibe configuration
   - Relevant Neovim settings
   - Other plugins that might be relevant

## 💡 Feature Requests

When suggesting features:

1. **Use Case**: Explain why this feature would be useful
2. **Implementation**: Suggest how it might be implemented
3. **Configuration**: Consider how it would be configured
4. **Compatibility**: Ensure it fits with the plugin's goals

## 📋 Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes
4. **Add** tests if applicable
5. **Update** documentation
6. **Run** the test suite (`make test`)
7. **Run** the linter (`make lint`)
8. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
9. **Push** to your branch (`git push origin feature/amazing-feature`)
10. **Open** a Pull Request

### PR Guidelines
- Keep PRs focused and reasonably sized
- Include a clear description of changes
- Reference any related issues
- Ensure all tests pass
- Update documentation as needed

## 🏷️ Release Process

Releases are managed by the maintainers:
- Version numbers follow semantic versioning
- Changelog is updated for each release
- Releases are tagged and published to GitHub

## 📞 Getting Help

- **GitHub Discussions**: For questions and general discussion
- **GitHub Issues**: For bug reports and feature requests
- **Discord**: Join the NvChad Discord for community support

## 📄 License

By contributing to Nvibe, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- README.md acknowledgments

Thank you for contributing to Nvibe! 🚀