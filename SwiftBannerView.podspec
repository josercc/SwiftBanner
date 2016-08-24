Pod::Spec.new do |s|
  s.name         = "SwiftBannerView"
  s.version      = "1.0.0"
  s.summary      = "Swift For Banner View."
  s.description  = <<-DESC
  Can be recycled to support local Banner Swift version of the web pictures
                   DESC
  s.homepage     = "https://github.com/15038777234/SwiftBanner"
  s.license      = "MIT"
  s.author             = { "15038777234" => "15038777234@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/15038777234/SwiftBanner.git", :tag => s.version }
  s.source_files  = "SwiftBanner/SwiftBanner/SwiftBannerView/"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "SwiftBanner/SwiftBanner/SwiftBannerView/"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "SnapKit", "~> 0.22.0"


end
