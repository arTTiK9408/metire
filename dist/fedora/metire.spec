Name: metire
Version: 1.0
Release: 1
Summary: Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm
License: MIT
URL: https://github.com/arTTiK9408/metire
Source0: %{url}/archive/v%{version}.tar.gz
BuildRequires: dart

%description
Metire is a TUI Pomodoro timer made as a study project, written in Dart and powered by Nocterm.

%prep
%setup -q

%build
dart pub get
dart compile exe bin/metire.dart -o metire

%install
install -Dm755 metire %{buildroot}%{_bindir}/metire

%files
%{_bindir}/metire
