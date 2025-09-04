# CLAUDE.md

This file provides essential development guidance for Claude when working with the CreativeKit Desktop repository.

## 🧱 Core Development Philosophy

### Code Structure Limits
- **Files:** Never exceed 500 lines of code
- **Functions:** Keep under 50 lines with single responsibility
- **Classes:** Under 100 lines representing single concepts
- **Line length:** Max 100 characters (enforced by ruff/prettier)

### Design Principles
- **KISS:** Choose simple solutions over complex ones
- **YAGNI:** Don't build speculative features
- **Fail Fast:** Check for errors early, raise exceptions immediately
- **Single Responsibility:** Each module has one clear purpose

## 🛠️ Development Environment Setup

### Required Tools
```bash
# Frontend (Node.js 18+)
npm install              # Install dependencies
npm run dev             # Start development server

# Rust/Tauri
cargo tauri dev         # Start Tauri app
cargo test              # Run Rust tests

# Python AI Service (use uv, NOT pip)
cd python-service
uv venv                 # Create virtual environment
uv sync                 # Install dependencies
uv run python -m src.main  # Start AI service
```

### Critical Commands
```bash
# ALWAYS use rg instead of grep/find
rg "pattern"                    # Search files
rg --files -g "*.ts"           # Find TypeScript files
rg "useEffect" --type ts       # Search in specific file types

# Code quality checks
npm run lint                   # Frontend linting
npm run typecheck             # TypeScript checking
cargo clippy                  # Rust linting
uv run ruff check .           # Python linting
uv run ruff format .          # Python formatting
uv run mypy src/              # Python type checking

# Testing
npm test                      # Frontend tests
cargo test                    # Rust tests
uv run pytest               # Python tests
```

## 📁 Repository Structure

```
src-tauri/src/           # Rust backend
├── commands/            # Tauri commands (PDF, image processing)
├── services/            # Business logic
├── models/              # Data structures
└── utils/               # Utilities and error handling

src/                     # React frontend
├── components/          # UI components by feature
├── hooks/               # Custom React hooks
├── utils/               # Frontend utilities
└── types/               # TypeScript definitions

python-service/src/      # AI processing service
├── services/            # AI models (REMBG, upscaling)
├── models/              # Pydantic request/response models
└── utils/               # Image processing utilities
```

## 🎨 Code Style Guidelines

### TypeScript/React
```typescript
// Use strict typing
interface ProcessingRequest {
  fileId: string;
  operation: 'merge' | 'split' | 'compress';
  options: ProcessingOptions;
}

// Async/await pattern
const processFile = async (request: ProcessingRequest): Promise<ProcessingResult> => {
  try {
    const result = await invoke('process_pdf', request);
    return { success: true, data: result };
  } catch (error) {
    console.error('Processing failed:', error);
    return { success: false, error: error.message };
  }
};

// Descriptive naming
const handleFileDropped = useCallback((files: File[]) => {
  setSelectedFiles(files);
  validateFiles(files);
}, []);
```

### Rust
```rust
// Proper error handling with anyhow
use anyhow::{Context, Result};

pub fn process_pdf(request: ProcessingRequest) -> Result<ProcessingResult> {
    let file_data = std::fs::read(&request.file_path)
        .with_context(|| format!("Failed to read file: {}", request.file_path))?;
    
    // Use match for operations
    let result = match request.operation {
        ProcessingOperation::Merge => merge_pdfs(&file_data)?,
        ProcessingOperation::Split => split_pdf(&file_data)?,
        _ => return Err(anyhow::anyhow!("Unsupported operation")),
    };
    
    Ok(result)
}

// Logging with proper levels
use log::{info, warn, error};

#[tauri::command]
pub async fn remove_background(image_path: String) -> Result<String, String> {
    info!("Starting background removal for: {}", image_path);
    // ... implementation
}
```

### Python (AI Service)
```python
# Always use type hints and Pydantic
from pydantic import BaseModel, Field, validator
from pathlib import Path
from typing import Optional

class BackgroundRemovalRequest(BaseModel):
    """Request model for background removal."""
    image_path: Path = Field(..., description="Path to input image")
    output_path: Optional[Path] = Field(None, description="Output path")
    model_name: str = Field("u2net", description="AI model to use")
    
    @validator('image_path')
    def validate_image_exists(cls, v):
        if not v.exists():
            raise ValueError(f"Image file not found: {v}")
        return v

# Proper error handling
class ProcessingError(Exception):
    """Base exception for processing errors."""
    pass

# Use structured logging
import logging
logger = logging.getLogger(__name__)
```

## 🧪 Testing Requirements

### Test-Driven Development (TDD)
1. **Write test first** - Define expected behavior
2. **Watch it fail** - Ensure test actually tests something
3. **Write minimal code** - Just enough to pass
4. **Refactor** - Improve while keeping tests green

### Testing Patterns
```typescript
// Frontend: Use Vitest + Testing Library
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';

describe('PdfMerger', () => {
  it('should validate file types correctly', () => {
    // Test implementation
  });
});
```

```rust
// Rust: Use tokio-test for async tests
#[tokio::test]
async fn test_pdf_merge_success() {
    let result = process_pdf(valid_request).await;
    assert!(result.is_ok());
}
```

```python
# Python: Use pytest with fixtures
@pytest.fixture
def sample_image():
    with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
        img = Image.new('RGB', (100, 100), color='red')
        img.save(f.name)
        yield Path(f.name)
        Path(f.name).unlink()

def test_background_removal_success(sample_image):
    # Test implementation
    pass
```

## 🚨 Error Handling Patterns

### Create Domain-Specific Errors
```typescript
// Frontend
interface ProcessingError {
  code: string;
  message: string;
  details?: any;
}
```

```rust
// Rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ProcessingError {
    #[error("File not found: {path}")]
    FileNotFound { path: String },
    
    #[error("Invalid file format: expected {expected}, got {actual}")]
    InvalidFormat { expected: String, actual: String },
}
```

```python
# Python
class ProcessingError(Exception):
    """Base exception for processing errors."""
    pass

class InvalidImageError(ProcessingError):
    """Raised when image format is invalid."""
    pass
```

## ⚙️ Configuration Management

### Environment Variables
```typescript
// Frontend
const config = {
  apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:3000',
  maxFileSize: parseInt(import.meta.env.VITE_MAX_FILE_SIZE || '50000000'),
};
```

```rust
// Rust (use config crate)
#[derive(Debug, Deserialize)]
pub struct AppConfig {
    pub max_file_size: u64,
    pub python_service_url: String,
}
```

```python
# Python (use pydantic-settings)
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "CreativeKit AI Service"
    max_file_size: int = 50_000_000
    rembg_model: str = "u2net"
    
    class Config:
        env_file = ".env"
```

## 🔒 Security Guidelines

### File Access Security
```rust
// Always validate file paths to prevent directory traversal
#[tauri::command]
pub async fn read_user_file(path: String) -> Result<Vec<u8>, String> {
    let canonical_path = std::fs::canonicalize(&path)
        .map_err(|_| "Invalid file path")?;
    
    let allowed_dir = std::env::current_dir()
        .unwrap()
        .join("user_files");
    
    if !canonical_path.starts_with(allowed_dir) {
        return Err("File access denied".to_string());
    }
    
    std::fs::read(canonical_path)
        .map_err(|e| format!("Failed to read file: {}", e))
}
```

## 📊 Performance Requirements

### Critical Limits
- **App startup:** <3 seconds
- **Background removal:** <10 seconds per image
- **Memory usage:** <500MB for typical operations
- **Bundle size:** 15-25MB (Tauri advantage)

### Memory Management
```typescript
// Process large files in chunks to avoid memory issues
const CHUNK_SIZE = 1024 * 1024; // 1MB chunks

const processLargeFile = async (file: File): Promise<ProcessingResult> => {
  // Use streaming for files >10MB
  if (file.size > 10 * 1024 * 1024) {
    return processFileInChunks(file, CHUNK_SIZE);
  }
  return processFileDirectly(file);
};
```

## 🔧 Package Management Rules

### Critical: Use Correct Package Managers
```bash
# Frontend: Use npm (NOT yarn)
npm install package-name
npm install -D dev-package

# Rust: Use cargo
cargo add serde_json
cargo add --dev tokio-test

# Python: Use uv (NOT pip/poetry)
uv add requests
uv add --dev pytest
# NEVER edit pyproject.toml directly - always use uv add
```

## 🌊 Git Workflow

### Branch Naming
```bash
feature/pdf-merge-tool
fix/memory-leak-image-processing
docs/api-documentation
refactor/error-handling
test/background-removal-service
```

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**NEVER include "claude code" or "written by claude" in commit messages**

Example:
```
feat(pdf): add batch merge functionality

- Implement multi-file PDF merging with progress tracking
- Add drag-and-drop support for multiple files
- Include error handling for corrupted PDFs

Closes #42
```

### Daily Workflow
1. `git checkout main && git pull origin main`
2. `git checkout -b feature/your-feature`
3. Make changes + write tests
4. `git push origin feature/your-feature`
5. Create PR → Review → Merge to main

## ⚠️ Project-Specific Warnings

### File Path Handling
- **Windows:** Use `std::path::PathBuf` in Rust, never string concatenation
- **Cross-platform:** Always use `/` in frontend, let Tauri handle conversion
- **Python:** Use `pathlib.Path`, never string operations on paths

### AI Service Dependencies
- **REMBG models are large** - implement lazy loading
- **GPU detection** - gracefully fallback to CPU if CUDA unavailable
- **Model caching** - cache loaded models in memory, don't reload per request

### Tauri-Specific
- **IPC serialization** - keep data structures simple, avoid deeply nested objects
- **File system access** - use Tauri APIs, not direct filesystem access from frontend
- **Process spawning** - use Tauri's process API for external commands

### Performance Critical Paths
- **Background removal** - offload to Python service, never in main thread
- **PDF processing** - stream large files, don't load entirely into memory
- **Progress updates** - throttle updates to avoid UI flooding (max 10/second)

## 📚 Essential Documentation Links

- **Tauri:** https://tauri.app/v1/guides/
- **Rust Book:** https://doc.rust-lang.org/book/
- **React:** https://react.dev/learn
- **UV (Python):** https://github.com/astral-sh/uv
- **REMBG:** https://github.com/danielgatis/rembg

## 🎯 Testing Coverage Requirements

- **Unit tests:** 90%+ coverage for critical business logic
- **Integration tests:** All Tauri commands and Python API endpoints
- **E2E tests:** Core user workflows (file upload → processing → download)

### Test Organization
- Keep tests next to code they test
- Use descriptive test names: `test_user_can_merge_pdfs_when_valid_files_provided`
- Mock external dependencies (AI models, file system)
- Test error conditions, not just happy paths

---

## 📋 Quality Assurance Checklist

### Pre-Release Checklist

#### Functionality
- [ ] All PDF operations work correctly across different file types
- [ ] AI background removal achieves >95% accuracy
- [ ] Image upscaling maintains quality standards
- [ ] Batch processing handles large file sets without memory issues
- [ ] Error handling provides clear, actionable feedback

#### Performance
- [ ] App startup time <3 seconds
- [ ] Background removal <10 seconds per image
- [ ] Memory usage <500MB for typical operations
- [ ] No memory leaks during extended use
- [ ] Smooth UI interactions (60fps)

#### Cross-Platform
- [ ] Windows 10/11 compatibility
- [ ] macOS 10.15+ compatibility
- [ ] Linux (Ubuntu 20.04+) compatibility
- [ ] Consistent behavior across platforms
- [ ] Platform-specific installers work correctly

#### Security
- [ ] No sensitive data in logs
- [ ] Secure file access controls
- [ ] Proper input validation
- [ ] Code signing certificates applied
- [ ] Dependency vulnerabilities resolved

#### User Experience
- [ ] Intuitive drag-and-drop interface
- [ ] Clear progress indicators
- [ ] Helpful error messages
- [ ] Responsive design for different screen sizes
- [ ] Accessibility standards met (WCAG 2.1 AA)

## ⚠️ Important Development Notes

### Critical Guidelines

- **NEVER ASSUME OR GUESS** - When in doubt, ask for clarification
- **Always verify file paths and module names** before implementation
- **Test your code thoroughly** - No feature is complete without comprehensive tests
- **Document your decisions** - Future developers will thank you
- **Keep CLAUDE.md updated** - This document should evolve with the project

### File Size and Performance Limits

```rust
// Enforce file size limits
const MAX_FILE_SIZE: u64 = 100_000_000; // 100MB
const MAX_BATCH_FILES: usize = 50;
const MAX_CONCURRENT_OPERATIONS: usize = 3;

pub fn validate_file_constraints(files: &[FileInfo]) -> Result<(), ValidationError> {
    if files.len() > MAX_BATCH_FILES {
        return Err(ValidationError::TooManyFiles(files.len()));
    }
    
    for file in files {
        if file.size > MAX_FILE_SIZE {
            return Err(ValidationError::FileTooLarge {
                filename: file.name.clone(),
                size: file.size,
                max_size: MAX_FILE_SIZE,
            });
        }
    }
    
    Ok(())
}
```

### Memory Management

```typescript
// Frontend memory management for large files
const processLargeFile = async (file: File): Promise<ProcessingResult> => {
  // Use streaming for large files to avoid memory issues
  const CHUNK_SIZE = 1024 * 1024; // 1MB chunks
  
  return new Promise((resolve, reject) => {
    const fileReader = new FileReader();
    let offset = 0;
    const chunks: ArrayBuffer[] = [];
    
    const readNextChunk = () => {
      const slice = file.slice(offset, offset + CHUNK_SIZE);
      fileReader.readAsArrayBuffer(slice);
    };
    
    fileReader.onload = (e) => {
      if (e.target?.result) {
        chunks.push(e.target.result as ArrayBuffer);
        offset += CHUNK_SIZE;
        
        if (offset < file.size) {
          readNextChunk();
        } else {
          // Process all chunks
          processFileChunks(chunks)
            .then(resolve)
            .catch(reject);
        }
      }
    };
    
    fileReader.onerror = () => reject(new Error('File reading failed'));
    readNextChunk();
  });
};
```
## Tech Stack Documentation URLs

### Desktop Frameworks:
- **Tauri:** https://tauri.app/v1/guides/
- **React:** https://react.dev/learn
- **Vue.js:** https://vuejs.org/guide/
- **TypeScript:** https://www.typescriptlang.org/docs/
- **Vite:** https://vitejs.dev/guide/

### Backend & Processing:
- **Rust:** https://doc.rust-lang.org/book/
- **Node.js:** https://nodejs.org/en/docs/
- **Python:** https://docs.python.org/3/

### PDF Processing:
- **PDF-lib:** https://pdf-lib.js.org/
- **lopdf (Rust):** https://docs.rs/lopdf/latest/lopdf/
- **printpdf (Rust):** https://docs.rs/printpdf/latest/printpdf/
- **Poppler:** https://poppler.freedesktop.org/

### Image Processing:
- **image (Rust):** https://docs.rs/image/latest/image/
- **Sharp:** https://sharp.pixelplumbing.com/
- **OpenCV (Python):** https://docs.opencv.org/4.x/
- **ImageMagick:** https://imagemagick.org/script/command-line-processing.php

### AI/ML Components:
- **REMBG:** https://github.com/danielgatis/rembg
- **Real-ESRGAN:** https://github.com/xinntao/Real-ESRGAN
- **WAIFU2X:** https://github.com/nagadomi/waifu2x
- **BiRefNet:** https://github.com/ZhengPeng7/BiRefNet

### UI Frameworks:
- **Ant Design:** https://ant.design/docs/react/introduce
- **Material-UI:** https://mui.com/material-ui/getting-started/

### Build & Distribution:
- **Tauri CLI:** https://tauri.app/v1/guides/development/development-cycle
- **Cargo:** https://doc.rust-lang.org/cargo/

### Storage & Database:
- **SQLite:** https://www.sqlite.org/docs.html
- **rusqlite (Rust):** https://docs.rs/rusqlite/latest/rusqlite/
- **Tauri File System API:** https://tauri.app/v1/api/js/fs
---

This comprehensive guide ensures CreativeKit Desktop maintains high code quality, performance standards, and user experience throughout development. Update this document as new patterns and requirements emerge.

**Last Updated:** [Current Date]
**Version:** 2.0
**Maintained by:** CreativeKit Development Team