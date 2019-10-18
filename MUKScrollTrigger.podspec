Pod::Spec.new do |s|
  s.name             = "MUKScrollTrigger"
  s.version          = "1.0.0"
  s.summary          = "An observer of UIScrollView which triggers when a certain amount is scrolled."
  s.description      = <<-DESC
                        MUKScrollTrigger observes a UIScrollView instance and it monitors scrolled amount. When a
                        threshold is passed, it triggers.
                        This mechanism could be used to achieve infinite scroll of a table view, for example.
                       DESC
  s.homepage         = "https://github.com/muccy/MUKScrollTrigger"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/MUKScrollTrigger.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{h,m}'
  s.compiler_flags  = '-Wdocumentation'
end
