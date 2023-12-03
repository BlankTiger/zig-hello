const std = @import("std");

pub fn main() !void {
    const options = std.net.StreamServer.Options{ .reuse_port = true };
    var streamServer = std.net.StreamServer.init(options);
    defer streamServer.deinit();
    const address = std.net.Address.initIp4([_]u8{ 127, 0, 0, 1 }, 6969);
    const err = try streamServer.listen(address);
    std.log.err("Got error from server: {}", .{err});
    std.log.info("Listening on: {}", .{streamServer.listen_address});

    const welcomeMsg = "Welcome to my zig server!\nEnter your message: ";
    var close = false;
    while (!close) {
        const connection = try streamServer.accept();
        std.log.info("User connected: {}", .{connection});

        const writtenBytes = try connection.stream.write(welcomeMsg);
        std.log.info("Written bytes: {}", .{writtenBytes});

        var buf = [_]u8{0} ** 50;
        const readBytes = try connection.stream.read(&buf);
        std.log.info("Read bytes: {}", .{readBytes});
        std.log.info("Got message: {s}", .{buf});

        connection.stream.close();
        close = std.mem.eql(u8, std.mem.sliceAsBytes("close"[0..]), std.mem.sliceAsBytes(buf[0..5]));
        std.log.info("Closing server? {}", .{close});
    }

    std.log.info("Closing..", .{});
}
