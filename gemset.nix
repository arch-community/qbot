{
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16ixam4lni8b5lgx0whnax0imzh1dh10fy5r9pxs52n83yz5nbq3";
      type = "gem";
    };
    version = "6.1.4.1";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ccgvlj767ybps3pxlaa4iw77n7wbriw2sr8754id3ngjfap08ja";
      type = "gem";
    };
    version = "6.1.4.1";
  };
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo" "zeitwerk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19gx1jcq46x9d1pi1w8xq0bgvvfw239y4lalr8asm291gj3q3ds4";
      type = "gem";
    };
    version = "6.1.4.1";
  };
  ast = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  bottom = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18mqd9jq97w8sxmbxsdlvw54hd8zwfs2r8ysiax0spm16kp9879i";
      type = "gem";
    };
    version = "0.1.0";
  };
  colorize = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "133rqj85n400qk6g3dhf2bmfws34mak1wqihvh3bgy9jhajw580b";
      type = "gem";
    };
    version = "0.8.1";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nwad3211p7yv9sda31jmbyw6sdafzmdi2i2niaz6f0wk5nq9h0f";
      type = "gem";
    };
    version = "1.1.9";
  };
  crass = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  discordrb = {
    dependencies = ["discordrb-webhooks" "ffi" "opus-ruby" "rest-client" "websocket-client-simple"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "79b717099cf7ad2746be757e3a6a4bb32886ee4b";
      sha256 = "1sblrkbr2vzzcfvfg15700xj7ms6sm77jv2p4gh6dqxvk9iln1ri";
      type = "git";
      url = "https://github.com/shardlab/discordrb.git";
    };
    version = "3.4.2";
  };
  discordrb-webhooks = {
    dependencies = ["rest-client"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "4de9fa6b1853ca3fb7ba321a86712b39b9716c87";
      sha256 = "0yc9g1rjn78a23rxbkkpsnaf0g1ri96qjy7dbdb5b0cpw1vh61kb";
      type = "git";
      url = "https://github.com/anna328p/discordrb.git";
    };
    version = "3.4.2";
  };
  domain_name = {
    dependencies = ["unf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lcqjsmixjp52bnlgzh4lg9ppsk52x9hpwdjd53k8jnbah2602h0";
      type = "gem";
    };
    version = "0.5.20190701";
  };
  ethon = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bby4hbq96vnzcdbbybcbddin8dxdnj1ns758kcr4akykningqhh";
      type = "gem";
    };
    version = "0.14.0";
  };
  event_emitter = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "148k9qv8102l3m6klc24dwip79f9y4bjr5z19dckd7ffbjyrf9n7";
      type = "gem";
    };
    version = "0.2.6";
  };
  faraday = {
    dependencies = ["multipart-post"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "172dirvq89zk57rv42n00rhbc2qwv1w20w4zjm6zvfqz4rdpnrqi";
      type = "gem";
    };
    version = "0.17.4";
  };
  faraday-cookie_jar = {
    dependencies = ["faraday" "http-cookie"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00hligx26w9wdnpgsrf0qdnqld4rdccy8ym6027h5m735mpvxjzk";
      type = "gem";
    };
    version = "0.0.7";
  };
  faraday_middleware = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x7jgvpzl1nm7hqcnc8carq6yj1lijq74jv8pph4sb3bcpfpvcsc";
      type = "gem";
    };
    version = "0.14.0";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ssxcywmb3flxsjdg13is6k01807zgzasdhj4j48dm7ac59cmksn";
      type = "gem";
    };
    version = "1.15.4";
  };
  hashugar = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cp39xp9jzzwnr52a8cfwpmhmjrg0qx7si16np1lh3xns2y82m8a";
      type = "gem";
    };
    version = "1.0.1";
  };
  http-accept = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09m1facypsdjynfwrcv19xcb1mqg8z6kk31g8r33pfxzh838c9n6";
      type = "gem";
    };
    version = "1.7.0";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19370bc97gsy2j4hanij246hv1ddc85hw0xjb6sj7n1ykqdlx9l9";
      type = "gem";
    };
    version = "1.0.4";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vdd1kii40qhbr9n8qx71k2gskq6rkl8ygy8hw5hfj8bb5a364xf";
      type = "gem";
    };
    version = "1.8.11";
  };
  io-console = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pmafwxh8z1apnk7bb1ibnbhfrgb1jgilxm4j8d0fcqlc2ggmbja";
      type = "gem";
    };
    version = "0.5.9";
  };
  irb = {
    dependencies = ["reline"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03xvy9z717azh8yfb973ip8v45yswyf122pdkdkrbhrd245ymn8w";
      type = "gem";
    };
    version = "1.3.7";
  };
  kramdown = {
    dependencies = ["rexml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jdbcjv4v7sj888bv3vc6d1dg4ackkh7ywlmn9ln2g9alk7kisar";
      type = "gem";
    };
    version = "2.3.1";
  };
  kramdown-parser-gfm = {
    dependencies = ["kramdown"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a8pb3v951f4x7h968rqfsa19c8arz21zw1vaj42jza22rap8fgv";
      type = "gem";
    };
    version = "1.1.0";
  };
  log4r-color = {
    dependencies = ["colorize" "scribe"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10ps260lvcdm1p8py9r4g4aq38zyc86bmn5j8jk265vl6v8blp7i";
      type = "gem";
    };
    version = "1.2.2";
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nqcya57x2n58y1dify60i0dpla40n4yir928khp4nj5jrn9mgmw";
      type = "gem";
    };
    version = "2.12.0";
  };
  mediawiki_api = {
    dependencies = ["faraday" "faraday-cookie_jar" "faraday_middleware"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13kj68j6zvanwzjxvrvdf0p4xvsvzl0abds8isflp6m2h7iz5ybb";
      type = "gem";
    };
    version = "0.7.1";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zj12l9qk62anvk9bjvandpa6vy4xslil15wl6wlivyf51z773vh";
      type = "gem";
    };
    version = "3.3.1";
  };
  mime-types-data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z5wvk6qi4ws1kjh7xn1rfirqw5m72bwvqacck1fjpbh33pcrwxv";
      type = "gem";
    };
    version = "3.2021.0901";
  };
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lvxm91hi0pabnkkg47wh1siv56s6slm2mdq1idfm86dyfidfprq";
      type = "gem";
    };
    version = "2.6.1";
  };
  minitest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19z7wkhg59y8abginfrm2wzplz7py3va8fyngiigngqvsws6cwgl";
      type = "gem";
    };
    version = "5.14.4";
  };
  multipart-post = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zgw9zlwh2a6i1yvhhc4a84ry1hv824d6g2iw2chs3k5aylpmpfj";
      type = "gem";
    };
    version = "2.1.1";
  };
  narray = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1drn8bfp0gyk21lg4sy2hqrnr3f5zsb153h56j00wmx154ci1gvk";
      type = "gem";
    };
    version = "0.6.1.2";
  };
  netrc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  nokogiri = {
    dependencies = ["mini_portile2" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1v02g7k7cxiwdcahvlxrmizn3avj2q6nsjccgilq1idc89cr081b";
      type = "gem";
    };
    version = "1.12.5";
  };
  open_uri_redirections = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kn05dxh2mry50jwb3ssn9f3cdnzqa7r0xiyrh6zkn5i0sq2krir";
      type = "gem";
    };
    version = "0.2.1";
  };
  opus-ruby = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lyf2a8f1w1jk0qrl8h0gsydfalbh19g5k2c6xlq8j1sfzb0ij4d";
      type = "gem";
    };
    version = "1.0.1";
  };
  paint = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01fhvxdaqngldqa7r0jgnskr4iv2x2i0n3z28za8j4qszpvlcb7x";
      type = "gem";
    };
    version = "2.2.1";
  };
  parallel = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hkfpm78c2vs1qblnva3k1grijvxh87iixcnyd83s3lxrxsjvag4";
      type = "gem";
    };
    version = "1.21.0";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06ma6w87ph8lnc9z4hi40ynmcdnjv0p8x53x0s3fjkz4q2p6sxh5";
      type = "gem";
    };
    version = "3.0.2.0";
  };
  pluralkit-api = {
    dependencies = ["typhoeus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11sffddpgvh2rv8sclzchmg9xfga4jml9qrb9z9vhw907wmaw073";
      type = "gem";
    };
    version = "1.0.1";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "178k7r0xn689spviqzhvazzvxfq6fyjldxb3ywjbgipbfi4s8j1g";
      type = "gem";
    };
    version = "1.5.2";
  };
  rails-html-sanitizer = {
    dependencies = ["loofah"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09qrfi3pgllxb08r024lln9k0qzxs57v0slsj8616xf9c0cwnwbk";
      type = "gem";
    };
    version = "1.4.2";
  };
  rainbow = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bb2fpjspydr6x0s8pn1pqkzmxszvkfapv0p4627mywl7ky4zkhk";
      type = "gem";
    };
    version = "3.0.0";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1iik52mf9ky4cgs38fp2m8r6skdkq1yz23vh18lk95fhbcxb6a67";
      type = "gem";
    };
    version = "13.0.3";
  };
  rbnacl = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y8yzianlkc9w6sbqy8iy8l0yym0y6x7p5rjflkfixq76fqmhvzk";
      type = "gem";
    };
    version = "7.1.1";
  };
  regexp_parser = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vg7imjnfcqjx7kw94ccj5r78j4g190cqzi1i59sh4a0l940b9cr";
      type = "gem";
    };
    version = "2.1.1";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xdylmg3w30bbas939v1ws322afxdlfq6r7aqfbqhjmyhrbaanvz";
      type = "gem";
    };
    version = "0.2.7";
  };
  rest-client = {
    dependencies = ["http-accept" "http-cookie" "mime-types" "netrc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qs74yzl58agzx9dgjhcpgmzfn61fqkk33k1js2y5yhlvc5l19im";
      type = "gem";
    };
    version = "2.1.0";
  };
  rexml = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rmagick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z1qk9i18zma000cqd758av9ca0622ykwp2cwm1x4dv9c0vw03yg";
      type = "gem";
    };
    version = "4.2.3";
  };
  rss = {
    dependencies = ["rexml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b1zx07kr64kkpm4lssd4r1a1qyr829ppmfl85i4adcvx9mqfid0";
      type = "gem";
    };
    version = "0.2.9";
  };
  rubocop = {
    dependencies = ["parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03ivbqd5blsb7v5mhrzxvn23779rqpyrsm7l086pb6ihp47122qb";
      type = "gem";
    };
    version = "1.23.0";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06krbzlj49gjfmxpjwadfwqsqg5bgcp9k1fahyxxk3f6idqhkjbv";
      type = "gem";
    };
    version = "1.13.0";
  };
  rubocop-checkstyle_formatter = {
    dependencies = ["rubocop"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wacx2sq4kjrqmzw7igw8i9i2m2wipmkwf3hs45lpq6c34zrjv35";
      type = "gem";
    };
    version = "0.5.0";
  };
  ruby-graphviz = {
    dependencies = ["rexml"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "010m283gk4qgzxkgrldlnrglh8d5fn6zvrzm56wf5abd7x7b8aqw";
      type = "gem";
    };
    version = "1.2.5";
  };
  ruby-progressbar = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02nmaw7yx9kl7rbaan5pl8x5nn0y4j5954mzrkzi9i3dhsrps4nc";
      type = "gem";
    };
    version = "1.11.0";
  };
  ruby_figlet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a1blsaljddfkn86nsh33p0h9qk0m8ic3m6n6vvdvy2086rxggzz";
      type = "gem";
    };
    version = "0.6.1";
  };
  scribe = {
    dependencies = ["rake" "thrift_client"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mpxb1rcnlxr2vr92fbqb15l0lwpj90j602capan8ks07m3vak3z";
      type = "gem";
    };
    version = "0.2.4";
  };
  sqlite3 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lja01cp9xd5m6vmx99zwn4r7s97r1w5cb76gqd8xhbm1wxyzf78";
      type = "gem";
    };
    version = "1.4.2";
  };
  tf-idf-similarity = {
    dependencies = ["unicode_utils"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vghkjx91g86rd8l7r86d1khd1nlyhg6fa6qym5g8hhid7x3rpxq";
      type = "gem";
    };
    version = "0.2.0";
  };
  thrift = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02p107kwx7jnkh6fpdgvaji0xdg6xkaarngkqjml6s4zny4m8slv";
      type = "gem";
    };
    version = "0.11.0.0";
  };
  thrift_client = {
    dependencies = ["thrift"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k7kh926z4dm4r9ak1v7xj0jwrdj595i6apzfgg3fbk3nsr4whnq";
      type = "gem";
    };
    version = "0.11.0";
  };
  typhoeus = {
    dependencies = ["ethon"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1m22yrkmbj81rzhlny81j427qdvz57yk5wbcf3km0nf3bl6qiygz";
      type = "gem";
    };
    version = "1.4.0";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10qp5x7f9hvlc0psv9gsfbxg4a7s0485wsbq1kljkxq94in91l4z";
      type = "gem";
    };
    version = "2.0.4";
  };
  unf = {
    dependencies = ["unf_ext"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jmbimpnpjdzz8hlrppgl9spm99qh3qzbx0b81k3gkgwba8nk3yd";
      type = "gem";
    };
    version = "0.0.8";
  };
  unicode-display_width = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0csjm9shhfik0ci9mgimb7hf3xgh7nx45rkd9rzgdz6vkwr8rzxn";
      type = "gem";
    };
    version = "2.1.0";
  };
  unicode_utils = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
      type = "gem";
    };
    version = "1.4.0";
  };
  websocket = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dib6p55sl606qb4vpwrvj5wh881kk4aqn2zpfapf8ckx7g14jw8";
      type = "gem";
    };
    version = "1.2.9";
  };
  websocket-client-simple = {
    dependencies = ["event_emitter" "websocket"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n7cjfg21lvszgr0w6w0c59qpwzpb7w4b3c7i3nxdpckabk76sx8";
      type = "gem";
    };
    version = "0.3.0";
  };
  word_wrap = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1iyc5bc7dbgsd8j3yk1i99ral39f23l6wapi0083fbl19hid8mpm";
      type = "gem";
    };
    version = "1.0.0";
  };
  zeitwerk = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1746czsjarixq0x05f7p3hpzi38ldg6wxnxxw74kbjzh1sdjgmpl";
      type = "gem";
    };
    version = "2.4.2";
  };
}
