// CreativeKit Runtime Hooks - Frontend Logging and Event System

import { invoke } from '@tauri-apps/api/tauri';

export interface LogEvent {
  level: 'info' | 'warn' | 'error' | 'debug';
  message: string;
  context?: Record<string, any>;
  timestamp: string;
  userId?: string;
}

export interface ProcessingEvent {
  type: 'file_processed' | 'error_occurred' | 'app_started' | 'feature_used';
  operation?: string;
  fileType?: string;
  duration?: number;
  success: boolean;
  error?: string;
  metadata?: Record<string, any>;
}

class CreativeKitHooks {
  private sessionId: string;
  private userId?: string;

  constructor() {
    this.sessionId = this.generateSessionId();
    this.initializeSession();
  }

  private generateSessionId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private async initializeSession(): Promise<void> {
    try {
      // Get user preferences for telemetry
      const telemetryEnabled = localStorage.getItem('telemetry_enabled') !== 'false';
      
      if (telemetryEnabled) {
        await this.logEvent({
          level: 'info',
          message: 'CreativeKit session started',
          context: {
            sessionId: this.sessionId,
            version: await this.getAppVersion(),
            platform: navigator.platform,
            userAgent: navigator.userAgent
          },
          timestamp: new Date().toISOString()
        });
      }
    } catch (error) {
      console.error('Failed to initialize session:', error);
    }
  }

  private async getAppVersion(): Promise<string> {
    try {
      return await invoke('get_app_version') as string;
    } catch {
      return 'unknown';
    }
  }

  // App lifecycle hooks
  async onAppStart(): Promise<void> {
    await this.logProcessingEvent({
      type: 'app_started',
      success: true,
      metadata: {
        startTime: Date.now(),
        sessionId: this.sessionId
      }
    });
  }

  async onFileProcessed(operation: string, fileType: string, duration: number, success: boolean, error?: string): Promise<void> {
    await this.logProcessingEvent({
      type: 'file_processed',
      operation,
      fileType,
      duration,
      success,
      error,
      metadata: {
        sessionId: this.sessionId,
        timestamp: Date.now()
      }
    });

    // Update usage statistics
    this.updateUsageStats(operation, fileType, success);
  }

  async onErrorOccurred(error: Error, context?: Record<string, any>): Promise<void> {
    await this.logEvent({
      level: 'error',
      message: error.message,
      context: {
        ...context,
        stack: error.stack,
        sessionId: this.sessionId,
        timestamp: Date.now()
      },
      timestamp: new Date().toISOString()
    });

    await this.logProcessingEvent({
      type: 'error_occurred',
      success: false,
      error: error.message,
      metadata: {
        errorType: error.constructor.name,
        sessionId: this.sessionId,
        context
      }
    });
  }

  async onFeatureUsed(featureName: string, metadata?: Record<string, any>): Promise<void> {
    await this.logProcessingEvent({
      type: 'feature_used',
      operation: featureName,
      success: true,
      metadata: {
        ...metadata,
        sessionId: this.sessionId,
        timestamp: Date.now()
      }
    });
  }

  // Logging methods
  private async logEvent(event: LogEvent): Promise<void> {
    try {
      // Check if telemetry is enabled
      const telemetryEnabled = localStorage.getItem('telemetry_enabled') !== 'false';
      if (!telemetryEnabled && event.level !== 'error') {
        return;
      }

      // Log to Rust backend for file persistence
      await invoke('log_event', { event });

      // Also log to console in development
      if (process.env.NODE_ENV === 'development') {
        console.log(`[${event.level.toUpperCase()}] ${event.message}`, event.context);
      }
    } catch (error) {
      // Fallback to console if backend logging fails
      console.error('Failed to log event:', error);
      console.log(`[${event.level.toUpperCase()}] ${event.message}`, event.context);
    }
  }

  private async logProcessingEvent(event: ProcessingEvent): Promise<void> {
    try {
      await invoke('log_processing_event', { event });
    } catch (error) {
      console.error('Failed to log processing event:', error);
    }
  }

  private updateUsageStats(operation: string, fileType: string, success: boolean): void {
    try {
      const stats = JSON.parse(localStorage.getItem('usage_stats') || '{}');
      const key = `${operation}_${fileType}`;
      
      if (!stats[key]) {
        stats[key] = { total: 0, successful: 0, failed: 0 };
      }
      
      stats[key].total++;
      if (success) {
        stats[key].successful++;
      } else {
        stats[key].failed++;
      }
      
      stats.lastUpdated = Date.now();
      localStorage.setItem('usage_stats', JSON.stringify(stats));
    } catch (error) {
      console.error('Failed to update usage stats:', error);
    }
  }

  // Performance monitoring
  async measurePerformance<T>(operation: string, fn: () => Promise<T>): Promise<T> {
    const startTime = performance.now();
    let success = false;
    let error: string | undefined;

    try {
      const result = await fn();
      success = true;
      return result;
    } catch (e) {
      success = false;
      error = e instanceof Error ? e.message : 'Unknown error';
      throw e;
    } finally {
      const duration = performance.now() - startTime;
      await this.logProcessingEvent({
        type: 'file_processed',
        operation,
        duration,
        success,
        error,
        metadata: {
          sessionId: this.sessionId
        }
      });
    }
  }

  // Error boundary integration
  async handleGlobalError(error: ErrorEvent | PromiseRejectionEvent): Promise<void> {
    let errorMessage: string;
    let errorContext: Record<string, any> = {};

    if (error instanceof ErrorEvent) {
      errorMessage = error.message;
      errorContext = {
        filename: error.filename,
        lineno: error.lineno,
        colno: error.colno,
        type: 'ErrorEvent'
      };
    } else {
      errorMessage = error.reason?.toString() || 'Unhandled promise rejection';
      errorContext = {
        type: 'PromiseRejectionEvent',
        reason: error.reason
      };
    }

    await this.logEvent({
      level: 'error',
      message: errorMessage,
      context: {
        ...errorContext,
        sessionId: this.sessionId,
        userAgent: navigator.userAgent,
        timestamp: Date.now()
      },
      timestamp: new Date().toISOString()
    });
  }

  // Telemetry management
  setTelemetryEnabled(enabled: boolean): void {
    localStorage.setItem('telemetry_enabled', enabled.toString());
  }

  isTelemetryEnabled(): boolean {
    return localStorage.getItem('telemetry_enabled') !== 'false';
  }

  // Get usage statistics for export
  getUsageStats(): Record<string, any> {
    try {
      return JSON.parse(localStorage.getItem('usage_stats') || '{}');
    } catch {
      return {};
    }
  }

  // Export logs (for support/debugging)
  async exportLogs(): Promise<string> {
    try {
      return await invoke('export_logs') as string;
    } catch (error) {
      throw new Error(`Failed to export logs: ${error}`);
    }
  }

  // Clear logs and stats
  async clearLogs(): Promise<void> {
    try {
      await invoke('clear_logs');
      localStorage.removeItem('usage_stats');
    } catch (error) {
      throw new Error(`Failed to clear logs: ${error}`);
    }
  }
}

// Global instance
export const hooks = new CreativeKitHooks();

// React hook for easy integration
export function useCreativeKitHooks() {
  return {
    onFileProcessed: hooks.onFileProcessed.bind(hooks),
    onErrorOccurred: hooks.onErrorOccurred.bind(hooks),
    onFeatureUsed: hooks.onFeatureUsed.bind(hooks),
    measurePerformance: hooks.measurePerformance.bind(hooks),
    getUsageStats: hooks.getUsageStats.bind(hooks),
    exportLogs: hooks.exportLogs.bind(hooks),
    clearLogs: hooks.clearLogs.bind(hooks),
    setTelemetryEnabled: hooks.setTelemetryEnabled.bind(hooks),
    isTelemetryEnabled: hooks.isTelemetryEnabled.bind(hooks)
  };
}

// Initialize global error handling
window.addEventListener('error', (error) => {
  hooks.handleGlobalError(error);
});

window.addEventListener('unhandledrejection', (error) => {
  hooks.handleGlobalError(error);
});

// Initialize app start hook
hooks.onAppStart();