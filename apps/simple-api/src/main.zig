const std = @import("std");
const httpz = @import("httpz");

const App = struct {
    pub fn dispatch(self: *App, action: httpz.Action(*App), req: *httpz.Request, res: *httpz.Response) !void {
        var timer = try std.time.Timer.start();

        try action(self, req, res);

        const elapsed = timer.lap() / 1000;
        std.log.info("{} {s} {d}", .{ req.method, req.url.path, elapsed });
    }

    pub fn notFound(_: *App, req: *httpz.Request, res: *httpz.Response) !void {
        std.log.info("404 {} {s}", .{ req.method, req.url.path });
        res.status = 404;
        res.body = "Not Found";
    }

    pub fn uncaughtError(_: *App, req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
        std.log.info("500 {} {s} {}", .{ req.method, req.url.path, err });
        res.status = 500;
        res.body = "sorry";
    }
};

const defaultJsonOptions: std.json.StringifyOptions = .{
    .emit_nonportable_numbers_as_strings = true,
    .whitespace = .indent_4,
    .emit_null_optional_fields = false,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const port = 8080;
    const serviceName = "simple-api";

    var app = App{};
    var server = try httpz.Server(*App).init(allocator, .{ .port = port }, &app);
    defer {
        std.log.info("Shutting down {s}", .{serviceName});
        server.stop();
        server.deinit();
    }

    const router = try server.router(.{});

    router.get("/health", health, .{});
    router.get("/alive", alive, .{});
    router.get("/", greet, .{});

    std.log.info("{s} listening at port {}", .{ serviceName, port });
    try server.listen();
}

fn greet(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;

    const query = try req.query();
    const name = query.get("name") orelse "World";
    const message = try std.fmt.allocPrint(res.arena, "Hello, {s}!", .{name});

    res.status = 200;
    try res.json(.{ .message = message }, defaultJsonOptions);
}

fn health(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    res.status = 200;
    res.content_type = httpz.ContentType.TEXT;
    res.body = "Healthy";
}

fn alive(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    _ = app;
    _ = req;

    res.status = 200;
    res.content_type = httpz.ContentType.TEXT;
    res.body = "Healthy";
}

test "should run tests" {
    try std.testing.expect(true);
}
