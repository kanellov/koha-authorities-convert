# Unimarc authorities to marc21

This koha plugin converts authorities from iso2709 unimarc to marc21. 

## Requirements

- Koha 3.12 +
- [MARC::Moose](http://search.cpan.org/dist/marc-moose/)

## Installation

Install MARC::Moose library through cpan as root

``` terminal
sudo cpan install MARC::Moose
```

or 

``` terminal
perl -MCPAN -e 'install MARC::Moose'
```

Download the [.kpz](./plugin.kpz) and install plugin in koha from "Koha Administration" > "Manage Plugins". 

## Usage

1. In plugins home click on "Run tool" from current plugin.
2. In the form upload the authorities files you want to convert.
3. Click upload then convert.