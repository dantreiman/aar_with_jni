def aar_with_jni(name, android_library, custom_package="does.not.matter"):

  native.android_binary(
      name = name + "_jni",
      custom_package = "custom_package",
      deps = [android_library],
  )

  native.genrule(
      name = name,
      srcs = [android_library + ".aar", name + "_jni_unsigned.apk"],
      outs = [name + ".aar"],
      cmd = """
cp $(location {}.aar) $(location :{}.aar)
chmod +w $(location :{}.aar)
origdir=$$PWD
cd $$(mktemp -d)
unzip $$origdir/$(location :{}_jni_unsigned.apk) "lib/*"
cp -r lib jni
zip -r $$origdir/$(location :{}.aar) jni/*/*.so
""".format(android_library, name, name, name, name),
  )
