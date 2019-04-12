#
# Be sure to run `pod lib lint DLNA_UPnP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DLNA_UPnP'
  s.version          = '1.0.0'
  s.summary          = 'A short description of DLNA_UPnP.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ClaudeLi/DLNA_UPnP'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ClaudeLi' => 'claudeli@yeah.net' }
  s.source           = { :git => 'https://github.com/ClaudeLi/DLNA_UPnP.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.default_subspecs = 'UPnP'

  s.subspec 'UPnP' do |ss|
    ss.dependency 'DLNA_UPnP/GData'
    ss.dependency 'CocoaAsyncSocket'
    ss.source_files         = 'DLNA_UPnP/Classes/UPnP/*.{h,m}'
  end

  s.subspec 'GData' do |ss|
    ss.requires_arc = false
    ss.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
    ss.source_files         = 'DLNA_UPnP/Classes/GData/*.{h,m}'
  end
end
