# CreativeKit UI/UX Design System

## Typography

```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Inter", sans-serif;

/* Heading Hierarchy */
.page-title {
    font-size: 28px;
    font-weight: 600;
    color: #1a1a1a;
    letter-spacing: -0.5px;
}

.section-title {
    font-size: 18px;
    font-weight: 600;
    color: #1a1a1a;
}

.card-title {
    font-size: 16px;
    font-weight: 600;
    color: #1a1a1a;
}

.body-text {
    font-size: 14px;
    font-weight: 400;
    color: #666666;
    line-height: 1.5;
}

.small-text {
    font-size: 12px;
    font-weight: 400;
    color: #999999;
}
```

## Color Palette

```css
:root {
    /* Backgrounds */
    --bg-primary: #ffffff;
    --bg-secondary: #f8f9fa;
    --bg-sidebar: #2c2c2c;
    
    /* Text Colors */
    --text-primary: #1a1a1a;
    --text-secondary: #666666;
    --text-tertiary: #999999;
    --text-inverse: #ffffff;
    
    /* Interactive States */
    --hover-bg: #f0f0f0;
    --active-bg: #e8e8e8;
    --sidebar-hover: #1a1a1a;
    
    /* Accent Colors */
    --accent-blue: #0066cc;
    --profile-color: #0066cc; /* Only for profile avatars */
    /* App logo colors allowed for brand recognition only */
}
```

## Icon Library

**Use Lucide Icons** - consistent, professional, minimal

### Navigation Icons
```html
<i data-lucide="layout-dashboard"></i>  <!-- Dashboard -->
<i data-lucide="tools"></i>             <!-- Tools -->
<i data-lucide="file-text"></i>         <!-- PDF Tools -->
<i data-lucide="image"></i>             <!-- Image Tools -->
<i data-lucide="qr-code"></i>           <!-- QR Generator -->
<i data-lucide="folder"></i>            <!-- Files -->
<i data-lucide="settings"></i>          <!-- Settings -->
<i data-lucide="download"></i>          <!-- Updates -->
```

### Interface Icons
```html
<i data-lucide="search"></i>            <!-- Search -->
<i data-lucide="bell"></i>              <!-- Notifications -->
<i data-lucide="user"></i>              <!-- Profile -->
<i data-lucide="filter"></i>            <!-- Filter -->
<i data-lucide="arrow-up-down"></i>     <!-- Sort -->
<i data-lucide="grid-3x3"></i>          <!-- Grid view -->
<i data-lucide="list"></i>              <!-- List view -->
<i data-lucide="plus"></i>              <!-- Add/Create -->
<i data-lucide="chevron-down"></i>      <!-- Dropdown -->
```

## Left Panel Structure

```
Dashboard
Tools ▼
├── PDF Tools
├── Image Tools
└── QR Generator
Files
─────────────────────
Settings
Updates
```

### Sidebar CSS
```css
.sidebar {
    width: 240px;
    background: var(--bg-sidebar);
    color: var(--text-tertiary);
    padding: 16px 0;
}

.nav-category-title {
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin: 24px 16px 8px;
    color: var(--text-tertiary);
}

.nav-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 16px;
    margin: 2px 8px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    color: var(--text-tertiary);
}

.nav-item:hover {
    background: var(--sidebar-hover);
    color: var(--text-inverse);
    transform: translateX(2px);
}

.nav-item.active {
    background: var(--sidebar-hover);
    color: var(--text-inverse);
    border-left: 3px solid var(--accent-blue);
}
```

## Navigation Bar Layout

```
[Logo] [Search Bar] ──────────────────── [Notifications] [Profile]
```

### Navigation CSS
```css
.top-nav {
    display: flex;
    align-items: center;
    padding: 12px 24px;
    border-bottom: 1px solid #e8e8e8;
    background: var(--bg-primary);
}

.logo {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-right: 24px;
}

.search-bar {
    flex: 1;
    max-width: 400px;
    margin: 0 auto;
}

.nav-actions {
    display: flex;
    align-items: center;
    gap: 16px;
}
```

## Color Usage Rules

### Allowed Colors
- **Profile avatars only**: Blue accent (#0066cc)
- **App logos only**: Brand colors for recognition
- **Active states**: Blue accent borders/backgrounds
- **Everything else**: Black (#1a1a1a), grey scales, white

### Prohibited
- Colored icons in navigation
- Colored backgrounds on cards (except hover states)
- Multiple accent colors

## Animation & Hover States

```css
/* Sidebar Navigation */
.nav-item {
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.nav-item:hover {
    background: var(--sidebar-hover);
    color: var(--text-inverse);
    transform: translateX(2px);
}

/* Card Interactions */
.card {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

/* Button States */
.button {
    transition: all 0.2s ease;
}

.button:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* Loading States */
.loading-spinner {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}
```

## File Management Features

### Filter Controls
```css
.file-filters {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
    padding: 0 24px;
}

.filter-button {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    background: var(--bg-primary);
    cursor: pointer;
    transition: all 0.2s ease;
}

.filter-button:hover {
    background: var(--hover-bg);
}

.filter-button.active {
    background: var(--accent-blue);
    color: white;
    border-color: var(--accent-blue);
}
```

### Sort Controls
```css
.sort-controls {
    display: flex;
    align-items: center;
    gap: 8px;
}

.sort-toggle {
    cursor: pointer;
    padding: 4px;
    border-radius: 4px;
    transition: background 0.2s ease;
    user-select: none;
}

.sort-toggle:hover {
    background: var(--hover-bg);
}
```

### Storage Display
```css
.storage-info {
    position: absolute;
    bottom: 16px;
    left: 16px;
    font-size: 12px;
    color: var(--text-tertiary);
    display: flex;
    align-items: center;
    gap: 8px;
}
```

## Dashboard Layout Structure

```html
<div class="dashboard">
    <!-- Compact Welcome Section -->
    <div class="welcome-section">
        <div class="profile-info">
            <img class="profile-avatar" src="..." alt="Profile">
            <div class="welcome-text">
                <h2 class="page-title">Welcome to CreativeKit, [Name]</h2>
                <p class="body-text">Professional License • <a href="#">View benefits</a></p>
            </div>
        </div>
    </div>
    
    <!-- Your Apps Grid -->
    <section class="apps-section">
        <h3 class="section-title">Your Apps</h3>
        <div class="apps-grid">
            <!-- 4-column responsive grid -->
        </div>
    </section>
    
    <!-- Recent Files -->
    <section class="recent-section">
        <div class="section-header">
            <h3 class="section-title">Recent</h3>
            <div class="section-controls">
                <!-- View toggles, sort, filter -->
            </div>
        </div>
        <div class="files-list">
            <!-- File list with thumbnails -->
        </div>
    </section>
</div>
```

### Dashboard CSS
```css
.welcome-section {
    padding: 32px 40px 24px;
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
    border-bottom: 1px solid #e8e8e8;
}

.profile-info {
    display: flex;
    align-items: center;
    gap: 16px;
}

.profile-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    border: 2px solid var(--accent-blue);
}

.apps-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 24px;
    padding: 24px 40px;
}

.app-card {
    padding: 24px;
    border: 1px solid #e8e8e8;
    border-radius: 12px;
    background: var(--bg-primary);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
```

## Files Page Structure

```html
<div class="files-page">
    <div class="page-header">
        <h1 class="page-title">Files</h1>
        <div class="header-actions">
            <button class="create-folder-btn">
                <i data-lucide="folder-plus"></i>
                Create Folder
            </button>
        </div>
    </div>
    
    <div class="files-controls">
        <div class="file-filters">
            <button class="filter-button active">All</button>
            <button class="filter-button">PDF</button>
            <button class="filter-button">Images</button>
            <button class="filter-button">Projects</button>
        </div>
        
        <div class="view-controls">
            <div class="sort-controls">
                <span>Sort by Name</span>
                <i data-lucide="arrow-up-down" class="sort-toggle"></i>
            </div>
            <div class="view-toggle">
                <i data-lucide="grid-3x3"></i>
                <i data-lucide="list"></i>
            </div>
        </div>
    </div>
    
    <div class="files-content">
        <!-- File grid or list -->
    </div>
    
    <div class="storage-info">
        <i data-lucide="hard-drive"></i>
        <span>478 MB used of 2 GB</span>
    </div>
</div>
```

## Project Folder Feature

```html
<div class="project-folder">
    <div class="project-header">
        <div class="project-info">
            <div class="project-icon">
                <i data-lucide="folder"></i>
            </div>
            <div class="project-details">
                <h3>Project Name</h3>
                <p>3 files • Created Dec 15</p>
            </div>
        </div>
        <div class="project-actions">
            <button><i data-lucide="share"></i> Share</button>
            <button><i data-lucide="plus"></i> Add</button>
        </div>
    </div>
    
    <div class="project-empty-state">
        <i data-lucide="folder-plus" class="empty-icon"></i>
        <h4>Keep all your files together in a project</h4>
        <button class="add-files-btn">
            <i data-lucide="plus"></i>
            Add Files
        </button>
    </div>
</div>
```

## Updates Page Structure

```html
<div class="updates-page">
    <div class="page-header">
        <h1 class="page-title">Updates</h1>
    </div>
    
    <div class="updates-list">
        <div class="update-card">
            <div class="update-header">
                <div class="update-info">
                    <h3 class="card-title">Version 2.1.0</h3>
                    <span class="small-text">December 15, 2024</span>
                </div>
                <div class="update-status">
                    <span class="status-badge available">Available</span>
                </div>
            </div>
            <p class="body-text">Bug fixes and performance improvements for PDF processing tools.</p>
            <div class="update-actions">
                <button class="primary-button">Download Update</button>
                <button class="secondary-button">Release Notes</button>
            </div>
        </div>
        
        <div class="update-card installed">
            <div class="update-header">
                <div class="update-info">
                    <h3 class="card-title">Version 2.0.5</h3>
                    <span class="small-text">November 28, 2024</span>
                </div>
                <div class="update-status">
                    <span class="status-badge installed">Installed</span>
                </div>
            </div>
            <p class="body-text">Enhanced AI background removal accuracy and speed improvements.</p>
        </div>
    </div>
</div>
```

## Button Styles

```css
.primary-button {
    background: var(--accent-blue);
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.primary-button:hover {
    background: #0052a3;
    transform: translateY(-1px);
}

.secondary-button {
    background: transparent;
    color: var(--text-secondary);
    border: 1px solid #e0e0e0;
    padding: 10px 20px;
    border-radius: 8px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.secondary-button:hover {
    background: var(--hover-bg);
}
```

## Status Badges

```css
.status-badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.status-badge.available {
    background: #e3f2fd;
    color: #1976d2;
}

.status-badge.installed {
    background: #e8f5e8;
    color: #2e7d32;
}
```

## Responsive Breakpoints

```css
/* Mobile First Approach */
@media (max-width: 768px) {
    .sidebar {
        width: 60px; /* Collapsed on mobile */
    }
    
    .apps-grid {
        grid-template-columns: 1fr;
        gap: 16px;
        padding: 16px 20px;
    }
    
    .files-controls {
        flex-direction: column;
        gap: 12px;
        align-items: stretch;
    }
}

@media (min-width: 1200px) {
    .apps-grid {
        grid-template-columns: repeat(4, 1fr);
    }
}
```

## Implementation Notes

1. **Icon Loading**: Include Lucide icons via CDN or npm package
2. **Font Loading**: Use system fonts for performance
3. **Color Consistency**: Stick to defined color variables
4. **Animation Performance**: Use `transform` and `opacity` for smooth animations
5. **Accessibility**: Ensure proper contrast ratios and keyboard navigation
6. **Touch Targets**: Minimum 44px for interactive elements on mobile

---

This design system ensures consistency with Adobe's professional aesthetic while maintaining CreativeKit's unique identity through minimal color usage and clean typography.