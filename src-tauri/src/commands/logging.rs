// CreativeKit Rust Backend - Logging Commands

use serde::{Deserialize, Serialize};
use std::fs::{File, OpenOptions};
use std::io::{BufWriter, Write};
use std::path::PathBuf;
use tauri::{AppHandle, Manager};
use chrono::{DateTime, Utc};
use anyhow::{Context, Result};

#[derive(Debug, Serialize, Deserialize)]
pub struct LogEvent {
    pub level: String,
    pub message: String,
    pub context: Option<serde_json::Value>,
    pub timestamp: String,
    pub user_id: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ProcessingEvent {
    pub r#type: String,
    pub operation: Option<String>,
    pub file_type: Option<String>,
    pub duration: Option<f64>,
    pub success: bool,
    pub error: Option<String>,
    pub metadata: Option<serde_json::Value>,
}

pub struct LoggingService {
    app_handle: AppHandle,
    log_dir: PathBuf,
}

impl LoggingService {
    pub fn new(app_handle: AppHandle) -> Result<Self> {
        let app_dir = app_handle
            .path_resolver()
            .app_data_dir()
            .context("Failed to get app data directory")?;
        
        let log_dir = app_dir.join("logs");
        std::fs::create_dir_all(&log_dir)
            .context("Failed to create logs directory")?;

        Ok(Self {
            app_handle,
            log_dir,
        })
    }

    fn get_log_file_path(&self, log_type: &str) -> PathBuf {
        let today = chrono::Utc::now().format("%Y-%m-%d").to_string();
        self.log_dir.join(format!("{}-{}.log", log_type, today))
    }

    pub fn write_log_event(&self, event: &LogEvent) -> Result<()> {
        let log_file_path = self.get_log_file_path("app");
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(log_file_path)
            .context("Failed to open log file")?;

        let log_entry = serde_json::json!({
            "timestamp": event.timestamp,
            "level": event.level,
            "message": event.message,
            "context": event.context,
            "user_id": event.user_id
        });

        writeln!(file, "{}", log_entry)
            .context("Failed to write log entry")?;

        Ok(())
    }

    pub fn write_processing_event(&self, event: &ProcessingEvent) -> Result<()> {
        let log_file_path = self.get_log_file_path("processing");
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(log_file_path)
            .context("Failed to open processing log file")?;

        let log_entry = serde_json::json!({
            "timestamp": chrono::Utc::now().to_rfc3339(),
            "type": event.r#type,
            "operation": event.operation,
            "file_type": event.file_type,
            "duration_ms": event.duration,
            "success": event.success,
            "error": event.error,
            "metadata": event.metadata
        });

        writeln!(file, "{}", log_entry)
            .context("Failed to write processing log entry")?;

        Ok(())
    }

    pub fn export_logs(&self) -> Result<String> {
        let mut all_logs = Vec::new();

        // Collect all log files
        let log_files = std::fs::read_dir(&self.log_dir)
            .context("Failed to read logs directory")?;

        for entry in log_files {
            let entry = entry.context("Failed to read log file entry")?;
            let path = entry.path();
            
            if path.extension().and_then(|s| s.to_str()) == Some("log") {
                let content = std::fs::read_to_string(&path)
                    .with_context(|| format!("Failed to read log file: {:?}", path))?;
                
                all_logs.push(format!("=== {} ===\n{}\n", path.file_name().unwrap().to_string_lossy(), content));
            }
        }

        Ok(all_logs.join("\n"))
    }

    pub fn clear_logs(&self) -> Result<()> {
        let log_files = std::fs::read_dir(&self.log_dir)
            .context("Failed to read logs directory")?;

        for entry in log_files {
            let entry = entry.context("Failed to read log file entry")?;
            let path = entry.path();
            
            if path.extension().and_then(|s| s.to_str()) == Some("log") {
                std::fs::remove_file(&path)
                    .with_context(|| format!("Failed to remove log file: {:?}", path))?;
            }
        }

        Ok(())
    }

    pub fn get_log_summary(&self) -> Result<serde_json::Value> {
        let mut summary = serde_json::json!({
            "total_logs": 0,
            "log_files": [],
            "latest_events": []
        });

        let log_files = std::fs::read_dir(&self.log_dir)
            .context("Failed to read logs directory")?;

        for entry in log_files {
            let entry = entry.context("Failed to read log file entry")?;
            let path = entry.path();
            
            if path.extension().and_then(|s| s.to_str()) == Some("log") {
                let metadata = entry.metadata()
                    .context("Failed to get file metadata")?;
                
                let file_info = serde_json::json!({
                    "name": path.file_name().unwrap().to_string_lossy(),
                    "size": metadata.len(),
                    "modified": metadata.modified()
                        .ok()
                        .and_then(|t| DateTime::<Utc>::from(t).to_rfc3339().parse::<String>().ok())
                });

                summary["log_files"].as_array_mut().unwrap().push(file_info);
            }
        }

        Ok(summary)
    }
}

// Tauri commands
#[tauri::command]
pub async fn log_event(
    app_handle: AppHandle,
    event: LogEvent,
) -> Result<(), String> {
    let logging_service = LoggingService::new(app_handle)
        .map_err(|e| format!("Failed to initialize logging service: {}", e))?;

    logging_service
        .write_log_event(&event)
        .map_err(|e| format!("Failed to log event: {}", e))?;

    Ok(())
}

#[tauri::command]
pub async fn log_processing_event(
    app_handle: AppHandle,
    event: ProcessingEvent,
) -> Result<(), String> {
    let logging_service = LoggingService::new(app_handle)
        .map_err(|e| format!("Failed to initialize logging service: {}", e))?;

    logging_service
        .write_processing_event(&event)
        .map_err(|e| format!("Failed to log processing event: {}", e))?;

    Ok(())
}

#[tauri::command]
pub async fn export_logs(app_handle: AppHandle) -> Result<String, String> {
    let logging_service = LoggingService::new(app_handle)
        .map_err(|e| format!("Failed to initialize logging service: {}", e))?;

    logging_service
        .export_logs()
        .map_err(|e| format!("Failed to export logs: {}", e))
}

#[tauri::command]
pub async fn clear_logs(app_handle: AppHandle) -> Result<(), String> {
    let logging_service = LoggingService::new(app_handle)
        .map_err(|e| format!("Failed to initialize logging service: {}", e))?;

    logging_service
        .clear_logs()
        .map_err(|e| format!("Failed to clear logs: {}", e))?;

    Ok(())
}

#[tauri::command]
pub async fn get_log_summary(app_handle: AppHandle) -> Result<serde_json::Value, String> {
    let logging_service = LoggingService::new(app_handle)
        .map_err(|e| format!("Failed to initialize logging service: {}", e))?;

    logging_service
        .get_log_summary()
        .map_err(|e| format!("Failed to get log summary: {}", e))
}

#[tauri::command]
pub async fn get_app_version() -> Result<String, String> {
    Ok(env!("CARGO_PKG_VERSION").to_string())
}