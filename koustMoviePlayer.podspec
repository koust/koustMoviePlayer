Pod::Spec.new do |s|
s.name         = "koustMoviePlayer"
s.version      = "1.0.1"
s.summary      = "koustMoviePlayer is similar netflix player. Almost , available all features on koustMoviePlayer"
s.license      = { :type => 'MIT License', :file => 'LICENSE' }
s.homepage     = "https://github.com/koust/koustMoviePlayer"
s.screenshots  = "https://github.com/koust/koustMoviePlayer/raw/master/koustMoviePlayerImage.png"
s.author       = { "koust" => "https://github.com/koust" }
s.platform     = :ios, "10.0"
s.swift_version = "4.2"
s.source       = { :git => "https://github.com/koust/koustMoviePlayer.git", :tag => s.version }
s.source_files  = "koustMoviePlayer/class/**/*"
s.resource_bundles = {
'Assets' => ['koustMoviePlayer/class/Assets/*.{png}']
}

s.requires_arc = true
end
