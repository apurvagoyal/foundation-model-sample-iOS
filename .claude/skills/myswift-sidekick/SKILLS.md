---
name: myswift-sidekick
description: Write, review, or improve Swift code following best practices for memory management, better performance, safer coding etc. Use when building new Swift functions, reviewing code quality, or adopting modern Swift SDKs.
---

## Overview
Use this skill when writing any Swift code features with correct state management, optimal view composition, and iOS 26+ adoption wherever possible. Prioritize native APIs, Apple design guidance, and performance-conscious patterns. This skill focuses on facts and best practices without enforcing specific architectural patterns.

## Memory Management

### Implement Weak Self
- **Always use weak self in closures to prevent memory leak** as shown below-

```swift
loadData { [weak self] data in 
  guard let self else { return }

  // use data
}
```




