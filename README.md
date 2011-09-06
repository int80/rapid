# What is Rapid?
Rapid is a reusuable framework for developing Perl applications. It
aims to provide a common base of useful functions for building
libraries of code that can have multiple interfaces, including
command-line scripts and web frontends.

# How is this different from Catalyst?
Catalyst is a framework for building web applications, but it does not provide a mechanism for code reuse in non-web contexts (cron jobs, scripts, CLI apps). Rapid is built upon [Catalyst::Plugin::Bread::Board](https://metacpan.org/module/Catalyst::Plugin::Bread::Board) which allows the creation and access of reusable components such as DBIC schemas, application configuration and templates. It harmonizes the usage of these components between Catalyst and non-Catalyst modules.

# What else does Rapid do for me?
TBD