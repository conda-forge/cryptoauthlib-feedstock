# check for missing libudev.so.0 and work around if necessary
echo "libudev fix"
LIBCRTYPOAUTH_PATH="$PREFIX/lib/libcryptoauth.so"
if ldd "$CRYPTOAUTH_PATH" | grep -q 'libudev\.so\.0.*not found'; then
    # rename libudev.so.0 to libudev.so.1 in the library so we can find it
    TMPLIB=$(mktemp -t libcryptoauth-XXXXXXXXXX.so)
    patchelf --replace-needed libudev.so.0 libudev.so.1 --output "$TMPLIB" "$LIBCRYPTOAUTH_PATH"
    # get the path to libudev.so.1
    chmod +x "$TMPLIB"
    LIBUDEV_PATH=$(ldd "$TMPLIB" | grep libudev.so.1 | sed -n 's,[^/]*\(/.*\) (0x.*,\1,p')
    rm "$TMPLIB"
    # link libudev.so.0 to libudev.so.1 for this environment
    ln -s "$LIBUDEV_PATH" "$PREFIX/lib/libudev.so.0"
fi
# exit cleanly no matter what
exit 0
