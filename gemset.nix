{
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09rsyd5v46d8lwk1a0c650ijg8jkbkfhvf9bgp89nwallqin9lcv";
      type = "gem";
    };
    version = "6.0.3.2";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ldl0ahqlx3h3fa0w8k60s1dlwc0wy947mm7ghpz18zrkf8jp5m8";
      type = "gem";
    };
    version = "6.0.3.2";
  };
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo" "zeitwerk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02sh4q8izyfdnh7z2nj5mn5sklfvqgx9rrag5j3l51y8aqkrg2yk";
      type = "gem";
    };
    version = "6.0.3.2";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fvchp2rhp2rmigx7qglf69xvjqvzq7x0g49naliw29r2bz656sy";
      type = "gem";
    };
    version = "2.7.0";
  };
  ast = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1l3468czzjmxl93ap40hp7z94yxp4nbag0bxqs789bm30md90m2a";
      type = "gem";
    };
    version = "2.4.1";
  };
  climate_control = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q11v0iabvr6rif0d025xh078ili5frrihlj0m04zfg7lgvagxji";
      type = "gem";
    };
    version = "0.2.0";
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
      sha256 = "094387x4yasb797mv07cs3g6f08y56virc2rjcpb1k79rzaj3nhl";
      type = "gem";
    };
    version = "1.1.6";
  };
  declarative = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yczgnqrbls7shrg63y88g7wand2yp9h6sf56c9bdcksn5nds8c0";
      type = "gem";
    };
    version = "0.0.20";
  };
  declarative-option = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g4ibxq566f1frnhdymzi9hxxcm4g2gw4n21mpjk2mhwym4q6l0p";
      type = "gem";
    };
    version = "0.1.0";
  };
  discordrb = {
    dependencies = ["discordrb-webhooks" "ffi" "opus-ruby" "rest-client" "websocket-client-simple"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "a15f81cb80f416b10f3ad8578fad563017a9071b";
      sha256 = "1w6zwiz6jc0540ggifsn0v2sf6xi7fn6jrr1jid8hqy0g000jwgx";
      type = "git";
      url = "https://github.com/swarley/discordrb.git";
    };
    version = "3.3.0";
  };
  discordrb-webhooks = {
    dependencies = ["rest-client"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "4eadc9296dabf08b89a29e8c0b177664c48c6f88";
      sha256 = "1srrimaswjyqf3vab8qwz224pz77p9lkags06zyfc6y3cmbm6qjf";
      type = "git";
      url = "https://github.com/anna328p/discordrb";
    };
    version = "3.3.0";
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
      sha256 = "13aghksmni2sl15y7wfpx6k5l3lfd8j9gdyqi6cbw6jgc7bqyyn2";
      type = "gem";
    };
    version = "0.17.3";
  };
  faraday-cookie_jar = {
    dependencies = ["faraday" "http-cookie"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1di4gx6446a6zdkrpj679m5k515i53wvb4yxcsqvy8d8zacxiiv6";
      type = "gem";
    };
    version = "0.0.6";
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
      sha256 = "12lpwaw82bb0rm9f52v1498bpba8aj2l2q359mkwbxsswhpga5af";
      type = "gem";
    };
    version = "1.13.1";
  };
  google-api-client = {
    dependencies = ["addressable" "googleauth" "httpclient" "mini_mime" "representable" "retriable" "signet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r8n2q50g8n249jr4rn493cfyii5rgm38chfdccpvmyshcq0q968";
      type = "gem";
    };
    version = "0.41.1";
  };
  googleauth = {
    dependencies = ["faraday" "jwt" "memoist" "multi_json" "os" "signet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "016jaj1s27bbvi5hwp9vqlvnz7jpxsg7510gajrfbmdsv4qzlz48";
      type = "gem";
    };
    version = "0.13.0";
  };
  hashie = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02bsx12ihl78x0vdm37byp78jjw2ff6035y7rrmbd90qxjwxr43q";
      type = "gem";
    };
    version = "4.1.0";
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
  httmultiparty = {
    dependencies = ["httparty" "mimemagic" "multipart-post"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v5wj3n9d6gk7427jfd876mbkhkwfnxzh46cf5bnxwpr7x0ga2sv";
      type = "gem";
    };
    version = "0.3.16";
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
      sha256 = "004cgs4xg5n6byjs7qld0xhsjq3n6ydfh897myr2mibvh6fjc49g";
      type = "gem";
    };
    version = "1.0.3";
  };
  httparty = {
    dependencies = ["mime-types" "multi_xml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17gpnbf2a7xkvsy20jig3ljvx8hl5520rqm9pffj2jrliq1yi3w7";
      type = "gem";
    };
    version = "0.18.1";
  };
  httpclient = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
    version = "2.8.3";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10nq1xjqvkhngiygji831qx9bryjwws95r4vrnlq9142bzkg670s";
      type = "gem";
    };
    version = "1.8.3";
  };
  io-console = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vbn4nvnr1pcmjsn0gghc3bz2md89njxq4801zi5dv5niypdxlsp";
      type = "gem";
    };
    version = "0.5.6";
  };
  irb = {
    dependencies = ["reline"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pg1n2wfg1i5nz5f0d995l5c1h1vby2sb6p0gsym7hccgr1gm2c4";
      type = "gem";
    };
    version = "1.2.4";
  };
  jwt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01zg1vp3lyl3flyjdkrcc93ghf833qgfgh2p1biqfhkzz11r129c";
      type = "gem";
    };
    version = "2.2.1";
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
  memoist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i9wpzix3sjhf6d9zw60dm4371iq8kyz7ckh2qapan2vyaim6b55";
      type = "gem";
    };
    version = "0.16.2";
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
      sha256 = "1z75svngyhsglx0y2f9rnil2j08f9ab54b3l95bpgz67zq2if753";
      type = "gem";
    };
    version = "3.2020.0512";
  };
  mimemagic = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qfqb9w76kmpb48frbzbyvjc0dfxh5qiw1kxdbv2y2kp6fxpa1kf";
      type = "gem";
    };
    version = "0.3.5";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1axm0rxyx3ss93wbmfkm78a6x03l8y4qy60rhkkiq0aza0vwq3ha";
      type = "gem";
    };
    version = "1.0.2";
  };
  minitest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09bz9nsznxgaf06cx3b5z71glgl0hdw469gqx3w7bqijgrb55p5g";
      type = "gem";
    };
    version = "5.14.1";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xy54mjf7xg41l8qrg1bqri75agdqmxap9z466fjismc1rn2jwfr";
      type = "gem";
    };
    version = "1.14.1";
  };
  multi_xml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lmd4f401mvravi1i1yq7b2qjjli0yq7dfc4p1nj5nwajp7r6hyj";
      type = "gem";
    };
    version = "0.6.0";
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
  os = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xnynckvrn9ailkmkrmkldnpv8hmmbdwxr7c7iz27cl1cpcdd49n";
      type = "gem";
    };
    version = "1.1.0";
  };
  paint = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "014b5rkbg6qri0cwkq972bfi93zvqdgswgvphjrgjl0pr6hywlkl";
      type = "gem";
    };
    version = "2.2.0";
  };
  parallel = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17b127xxmm2yqdz146qwbs57046kn0js1h8synv01dwqz2z1kp2l";
      type = "gem";
    };
    version = "1.19.2";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vlnnw46mim4hwi44wdmgq8dmmfypxg2cj06a64zwksbw55pki6l";
      type = "gem";
    };
    version = "2.7.1.5";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vywld400fzi17cszwrchrzcqys4qm6sshbv73wy5mwcixmrgg7g";
      type = "gem";
    };
    version = "4.0.5";
  };
  rainbow = {
    groups = ["default" "test"];
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
      sha256 = "0w6qza25bq1s825faaglkx1k6d59aiyjjk3yw3ip5sb463mhhai9";
      type = "gem";
    };
    version = "13.0.1";
  };
  rbnacl = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06xb4khgjblrmp1xgkjbmca0wl97i0nazf9pgx69vwr1ac03j920";
      type = "gem";
    };
    version = "3.4.0";
  };
  regexp_parser = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n9d14ppshnx71i3mi1pnm3hwhcbb6m6vsc0b0dqgsab8r2rs96n";
      type = "gem";
    };
    version = "1.8.1";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08sz3xb75v20if4pc9xfps89bg2dmhnnmpyalw0nxzypw76yn0z8";
      type = "gem";
    };
    version = "0.1.4";
  };
  representable = {
    dependencies = ["declarative" "declarative-option" "uber"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qm9rgi1j5a6nv726ka4mmixivlxfsg91h8rpp72wwd4vqbkkm07";
      type = "gem";
    };
    version = "3.0.4";
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
  retriable = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1q48hqws2dy1vws9schc0kmina40gy7sn5qsndpsfqdslh65snha";
      type = "gem";
    };
    version = "3.1.2";
  };
  rexml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mkvkcw9fhpaizrhca0pdgjcrbns48rlz4g6lavl5gjjq3rk2sq3";
      type = "gem";
    };
    version = "3.2.4";
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
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jrfcxs7qm2jamh44djz322c8xpg8zyllg6xyk0r0qnvk71dwlrn";
      type = "gem";
    };
    version = "0.92.0";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "129hgz4swc8n0g01715v7y00k0h4mlzkxh63q7z27q7mjp54rl74";
      type = "gem";
    };
    version = "0.7.1";
  };
  ruby-progressbar = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1k77i0d4wsn23ggdd2msrcwfy0i376cglfqypkk2q77r2l3408zf";
      type = "gem";
    };
    version = "1.10.1";
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
  signet = {
    dependencies = ["addressable" "faraday" "jwt" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10g2667fvxnc50hcd1aywgsbf8j7nrckg3n7zjvywmyz82pwmpqp";
      type = "gem";
    };
    version = "0.14.0";
  };
  soundcloud = {
    dependencies = ["hashie" "httmultiparty"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gfwnnqgvgbh4rnl1r5ffys81w9yx3h9zddkmjk3vvlibh4pgmjv";
      type = "gem";
    };
    version = "0.3.4";
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
  terrapin = {
    dependencies = ["climate_control"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p18f05r0c5s70571gqig3z2ym74wx79s6rd45sprp207bqskzn9";
      type = "gem";
    };
    version = "0.6.0";
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
  thread_safe = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
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
  tzinfo = {
    dependencies = ["thread_safe"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1i3jh086w1kbdj3k5l60lc3nwbanmzdf8yjj3mlrx9b2gjjxhi9r";
      type = "gem";
    };
    version = "1.2.7";
  };
  uber = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1p1mm7mngg40x05z52md3mbamkng0zpajbzqjjwmsyw0zw3v9vjv";
      type = "gem";
    };
    version = "0.1.0";
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
      sha256 = "0wc47r23h063l8ysws8sy24gzh74mks81cak3lkzlrw4qkqb3sg4";
      type = "gem";
    };
    version = "0.0.7.7";
  };
  unicode-display_width = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06i3id27s60141x6fdnjn5rar1cywdwy64ilc59cz937303q3mna";
      type = "gem";
    };
    version = "1.7.0";
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
      sha256 = "0f11rcn4qgffb1rq4kjfwi7di79w8840x9l74pkyif5arp0mb08x";
      type = "gem";
    };
    version = "1.2.8";
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
  "youtube-dl.rb" = {
    dependencies = ["terrapin"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "3504b8623eb14a3f58831c39ad678834d1b57ce4";
      sha256 = "1jxkdfimiqscacjvyw9zmj5xqslza3mqb6n3b4va6x948000dpwd";
      type = "git";
      url = "https://github.com/gkaklas/youtube-dl.rb.git";
    };
    version = "0.3.1.2016.09.11.1";
  };
  zeitwerk = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1akpm3pwvyiack2zk6giv9yn3cqb8pw6g40p4394pdc3xmy3s4k0";
      type = "gem";
    };
    version = "2.3.0";
  };
}