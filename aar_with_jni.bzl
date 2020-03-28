def aar_with_jni(name, android_library, custom_package):
  native.genrule(
      name = name + "_binary_manifest_generator",
      outs = [name + "_generated_AndroidManifest.xml"],
      cmd = """
cat > $(OUTS) <<EOF
<manifest
  xmlns:android="http://schemas.android.com/apk/res/android"
  package="{}">
  <uses-sdk android:minSdkVersion="23"/>
</manifest>
EOF
""".format(custom_package),
  )

  native.android_binary(
      name = name + "_jni",
      manifest = name + "_generated_AndroidManifest.xml",
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
