Pod::Spec.new do |s|
  s.name = 'cactus_v114'
  s.version = '1.14.0'
  s.summary = 'Cactus v1.14 native runtime for Tag.'
  s.description = 'Local vendored Cactus v1.14 iOS XCFramework used by Tag for on-device Gemma 4 and embeddings.'
  s.homepage = 'https://github.com/cactus-compute/cactus'
  s.license = { :type => 'Apache-2.0' }
  s.author = { 'Cactus Compute' => 'founders@cactuscompute.com' }
  s.source = { :path => '.' }

  s.platform = :ios, '16.0'
  s.vendored_frameworks = 'cactus.xcframework'
  s.frameworks = 'Accelerate', 'CFNetwork', 'CoreML', 'Foundation', 'Security', 'SystemConfiguration'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 x86_64'
  }
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 x86_64'
  }
end
