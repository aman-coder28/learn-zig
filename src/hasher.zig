const std = @import("std");
const print = std.debug.print;

pub fn encryptWithPassword(
    allocator: std.mem.Allocator,
    init: std.Io,
    plaintext: []const u8,
    password: []const u8,
) ![]u8 {
    var salt: [16]u8 = undefined;
    try std.Io.randomSecure(init, &salt);

    var key: [32]u8 = undefined;
    try std.crypto.pwhash.argon2.kdf(
        allocator,
        &key,
        password,
        &salt,
        std.crypto.pwhash.argon2.Params.owasp_2id,
        .argon2id,
        init,
    );

    const encrypted = try encrypt(allocator, init, plaintext, key);
    defer allocator.free(encrypted);

    const out = try allocator.alloc(u8, salt.len + encrypted.len);
    @memcpy(out[0..salt.len], &salt);
    @memcpy(out[salt.len..], encrypted);

    return out;
}

pub fn decryptWithPassword(
    allocator: std.mem.Allocator,
    init: std.Io,
    blob: []const u8,
    password: []const u8,
) ![]u8 {
    if (blob.len < 16) return error.InvalidInput;
    const salt = blob[0..16];

    var key: [32]u8 = undefined;
    try std.crypto.pwhash.argon2.kdf(
        allocator,
        &key,
        password,
        salt,
        std.crypto.pwhash.argon2.Params.owasp_2id,
        .argon2id,
        init,
    );

    return try decrypt(allocator, blob[16..], key);
}

pub fn encrypt(allocator: std.mem.Allocator, init: std.Io, plaintext: []const u8, key: [32]u8) ![]u8 {
    var nonce: [12]u8 = undefined;
    try std.Io.randomSecure(init, &nonce);

    const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;

    var out = try allocator.alloc(u8, Aes256Gcm.nonce_length + plaintext.len + Aes256Gcm.tag_length);
    errdefer allocator.free(out);

    @memcpy(out[0..Aes256Gcm.nonce_length], &nonce);

    const ciphertext = out[Aes256Gcm.nonce_length .. Aes256Gcm.nonce_length + plaintext.len];
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
