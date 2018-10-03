#
# Be sure to run `pod lib lint HSBTextView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'HSBTextView'
s.version          = '0.1.2'
s.summary          = 'Hash Tag TextView'
s.swift_version    = '4.2'
s.description      = <<-DESC
Hash Tag TextView.
DESC

s.homepage         = 'https://github.com/hsb9kr/HSBTextView'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Red' => 'hsb9kr@gmail.com' }
s.source           = { :git => 'https://github.com/hsb9kr/HSBTextView.git', :tag => s.version.to_s }
s.requires_arc          = true
s.ios.deployment_target = '8.0'

s.source_files = 'HSBTextView/Classes/*.swift'
s.frameworks = 'UIKit'
end
