#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_storm.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_storm'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'OTHER_LDFLAGS' => '-framework storm' }
  s.swift_version = '5.0'

  # build stormlib cmake project
  s.prepare_command = <<-CMD
    # if no StormLib folder, clone it
    if [ ! -d "StormLib" ]; then
      curl -fsSL https://api.github.com/repos/ladislav-zezula/StormLib/zipball/v9.24 -o stormlib.zip
      unzip -o stormlib.zip
      mv ladislav-zezula-StormLib-* StormLib
      rm stormlib.zip
    fi
    cd StormLib
    cmake -G Xcode -B build -DSTORM_SKIP_INSTALL=ON -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" -DBUILD_SHARED_LIBS=ON
    cmake --build build --config Release
  CMD

  # link stormlib
  s.vendored_frameworks = 'StormLib/build/Release/storm.framework'
end
