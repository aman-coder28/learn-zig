const std = @import("std");
const print = std.debug.print;

pub fn hashPassword(allocator: std.mem.Allocator, init: std.process.Init, password: []const u8, out_buf: []u8) ![]const u8 {
    return std.crypto.pwhash.argon2.strHash(
        password,
        .{
            .allocator = allocator,
            .params = std.crypto.pwhash.argon2.Params.owasp_2id,
        },
        out_buf,
        init.io,
    );
}

pub fn verifyPassword(allocator: std.mem.Allocator, stored_hash: []const u8, attempt: []const u8) !bool {
    _ = std.crypto.pwhash.argon2.strVerify(stored_hash, attempt, .{ .allocator = allocator }) catch return false;

    return true;
}

pub fn encrypt_aes_simple(word: *const [16]u8, key: [32]u8) ![16]u8 {
    var out: [16]u8 = undefined;

    var ctx = std.crypto.core.aes.Aes256.initEnc(key);
    ctx.encrypt(out[0..], word);

    return out;
}

pub fn decrypt_aes_simple(encrypted: *const [16]u8, key: [32]u8) ![16]u8 {
    var out: [16]u8 = undefined;

    var ctx = std.crypto.core.aes.Aes256.initDec(key);
    ctx.decrypt(out[0..], encrypted);

    return out;
}

pub fn encrypt(allocator: std.mem.Allocator, init: std.process.Init, plaintext: []const u8, key: [32]u8) ![]u8 {
    var nonce: [12]u8 = undefined;
    try std.Io.randomSecure(init.io, &nonce);

    const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;

    var out = try allocator.alloc(u8, Aes256Gcm.nonce_length + plaintext.len + Aes256Gcm.tag_length);
    errdefer allocator.free(out);

    @memcpy(out[0..Aes256Gcm.nonce_length], &nonce);

    const ciphertext = out[0..plaintext.len];
    var tag: [Aes256Gcm.tag_length]u8 = undefined;

    Aes256Gcm.encrypt(ciphertext, &tag, plaintext, &[_]u8{}, nonce, key);

    @memcpy(out[Aes256Gcm.nonce_length + plaintext.len ..], &tag);

    return out;
}

pub fn decrypt(allocator: std.mem.Allocator, blob: []const u8, key: [32]u8) ![]u8 {
    const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;
    const min_len = Aes256Gcm.nonce_length + Aes256Gcm.tag_length;

    if (blob.len < min_len) return error.InvalidInput;

    const nonce: [Aes256Gcm.nonce_length]u8 = blob[0..Aes256Gcm.nonce_length].*;
    const ciphertext = blob[Aes256Gcm.nonce_length .. blob.len - Aes256Gcm.tag_length];
    const tag: [Aes256Gcm.tag_length]u8 = blob[blob.len - Aes256Gcm.tag_length ..][0..Aes256Gcm.tag_length].*;

    const plaintext = try allocator.alloc(u8, ciphertext.len);
    errdefer allocator.free(plaintext);

    try Aes256Gcm.decrypt(plaintext, ciphertext, tag, &[_]u8{}, nonce, key);

    return plaintext;
}
