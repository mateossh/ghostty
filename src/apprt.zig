//! "apprt" is the "application runtime" package. This abstracts the
//! application runtime and lifecycle management such as creating windows,
//! getting user input (mouse/keyboard), etc.
//!
//! This enables compile-time interfaces to be built to swap out the underlying
//! application runtime. For example: glfw, pure macOS Cocoa, GTK+, browser, etc.
//!
//! The goal is to have different implementations share as much of the core
//! logic as possible, and to only reach out to platform-specific implementation
//! code when absolutely necessary.
const std = @import("std");
const builtin = @import("builtin");
const build_config = @import("build_config.zig");

pub usingnamespace @import("apprt/structs.zig");
pub const glfw = @import("apprt/glfw.zig");
pub const gtk = @import("apprt/gtk.zig");
pub const browser = @import("apprt/browser.zig");
pub const embedded = @import("apprt/embedded.zig");
pub const surface = @import("apprt/surface.zig");

/// The implementation to use for the app runtime. This is comptime chosen
/// so that every build has exactly one application runtime implementation.
/// Note: it is very rare to use Runtime directly; most usage will use
/// Window or something.
pub const runtime = switch (build_config.artifact) {
    .exe => switch (build_config.app_runtime) {
        .none => @compileError("exe with no runtime not allowed"),
        .glfw => glfw,
        .gtk => gtk,
    },
    .lib => embedded,
    .wasm_module => browser,
};

pub const App = runtime.App;
pub const Surface = runtime.Surface;

/// Runtime is the runtime to use for Ghostty. All runtimes do not provide
/// equivalent feature sets. For example, GTK offers tabbing and more features
/// that glfw does not provide. However, glfw may require many less
/// dependencies.
pub const Runtime = enum {
    /// Will not produce an executable at all when `zig build` is called.
    /// This is only useful if you're only interested in the lib only (macOS).
    none,

    /// Glfw-backed. Very simple. Glfw is statically linked. Tabbing and
    /// other rich windowing features are not supported.
    glfw,

    /// GTK-backed. Rich windowed application. GTK is dynamically linked.
    gtk,

    pub fn default(target: std.zig.CrossTarget) Runtime {
        _ = target;
        return .glfw;
    }
};

test {
    @import("std").testing.refAllDecls(@This());
}