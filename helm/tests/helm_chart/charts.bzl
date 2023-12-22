def get_charts():
    return [
        struct(name="a"),
        struct(name="b"),
        # struct(name="empty"),
        struct(name="noapiversion"),
        # struct(name="nomanifest"),
        struct(name="omitfiles", srcs=native.glob(["charts/omitfiles/**"], exclude = ["filetoremove.txt"])),
        struct(name="valuesschema"),
        struct(name="whole"),
        struct(name="wholemanifest"),
        # struct(name="withdeps"),
    ]
