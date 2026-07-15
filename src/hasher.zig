const std = @import("std");
const print = std.debug.print;

pub fn hash(word: []const u8, key: []const u8) ![32]u8 {
    var out: [32]u8 = undefined;

    std.crypto.auth.hmac.sha2.HmacSha256.create(&out, word, key);

    return out;
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

pub fn encrypt(allocator: std.mem.Allocator, plaintext: []const u8, key: [32]u8, nonce: [12]u8) ![]u8 {
    const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;

    var out = try allocator.alloc(u8, plaintext.len + Aes256Gcm.tag_length);
    errdefer allocator.free(out);

    const ciphertext = out[0..plaintext.len];
    var tag: [Aes256Gcm.tag_length]u8 = undefined;

    Aes256Gcm.encrypt(ciphertext, &tag, plaintext, &[_]u8{}, nonce, key);

    @memcpy(out[plaintext.len..], &tag);

    return out;
}

pub fn decrypt(allocator: std.mem.Allocator, ciphertext_with_tag: []const u8, key: [32]u8, nonce: [12]u8) ![]u8 {
    const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;

    if (ciphertext_with_tag.len < Aes256Gcm.tag_length) return error.InvalidInput;

    const ciphertext = ciphertext_with_tag[0 .. ciphertext_with_tag.len - Aes256Gcm.tag_length];

    var tag: [Aes256Gcm.tag_length]u8 = undefined;
    @memcpy(&tag, ciphertext_with_tag[ciphertext_with_tag.len - Aes256Gcm.tag_length ..]);

    const plaintext = try allocator.alloc(u8, ciphertext.len);
    errdefer allocator.free(plaintext);

    try Aes256Gcm.decrypt(plaintext, ciphertext, tag, &[_]u8{}, nonce, key);

    return plaintext;
}
