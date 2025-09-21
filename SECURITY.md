# Security Policy

## Reporting Security Vulnerabilities

**⚠️ IMPORTANT: Please do NOT create public issues for security vulnerabilities.**

If you discover a security vulnerability in Trinity Cortex, please report it privately:

### How to Report

1. **Email**: gonzacha@gmail.com with subject "[SECURITY] Trinity Cortex"
2. **GitHub Security Advisory**: Use GitHub's private vulnerability reporting (if enabled)

### What to Include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
- Your contact information

### Response Time

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution**: Based on severity (Critical: 24-48h, High: 1 week, Medium: 2 weeks)

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Measures

Trinity Cortex implements:
- Input sanitization for LLM interactions
- API key protection (environment variables only)
- Rate limiting for API calls
- No credential storage in code
- Prompt injection prevention

## Recognition

We appreciate responsible disclosure and will credit security researchers (with permission) in our release notes.
