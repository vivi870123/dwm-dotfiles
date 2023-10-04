local servers = {
  bashls = {},
  cssls = {},
  docker_compose_language_service = function()
    local lspconfig = require 'lspconfig'
    return {
      root_dir = lspconfig.util.root_pattern 'docker-compose.yml',
      filetypes = { 'yaml', 'dockerfile' },
    }
  end,
  emmet_ls = {
    filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less', 'blade', 'vue' },
    init_options = {
      html = {
        options = {
          -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
          ['bem.enabled'] = true,
        },
      },
    },
  },
  html = {
    filetypes = {
      'html',
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
  },
  prosemd_lsp = {},
  pyright = {},
  tailwindcss = {
    filetypes_exclude = { 'markdown' },
  },
  vimls = {},

  graphql = {
    on_attach = function(client)
      -- Disable workspaceSymbolProvider because this prevents
      -- searching for symbols in typescript files which this server
      -- is also enabled for.
      -- @see: https://github.com/nvim-telescope/telescope.nvim/issues/964
      client.server_capabilities.workspaceSymbolProvider = false
    end,
  },

  intelephense = function()
    return {
      settings = {
        intelephense = {
          format = { enable = false },
          diagnostics = { enable = false },
          stubs = {
            'aerospike',
            'amqp',
            'apache',
            'apcu',
            'ast',
            'bcmath',
            'blackfire',
            'bz2',
            'calendar',
            'cassandra',
            'com_dotnet',
            'Core',
            'couchbase',
            'couchbase_v2',
            'crypto',
            'ctype',
            'cubrid',
            'curl',
            'date',
            'dba',
            'decimal',
            'dio',
            'dom',
            'ds',
            'enchant',
            'Ev',
            'event',
            'exif',
            'fann',
            'FFI',
            'ffmpeg',
            'fileinfo',
            'filter',
            'fpm',
            'ftp',
            'gd',
            'gearman',
            'geoip',
            'geos',
            'gettext',
            'gmagick',
            'gmp',
            'gnupg',
            'grpc',
            'hash',
            'http',
            'ibm_db2',
            'iconv',
            'igbinary',
            'imagick',
            'imap',
            'inotify',
            'interbase',
            'intl',
            'json',
            'judy',
            'ldap',
            'leveldb',
            'libevent',
            'libsodium',
            'libvirt-php',
            'libxml',
            'lua',
            'LuaSandbox',
            'lzf',
            'mailparse',
            'mapscript',
            'mbstring',
            'mcrypt',
            'memcache',
            'memcached',
            'meminfo',
            'meta',
            'ming',
            'mongo',
            'mongodb',
            'mosquitto-php',
            'mqseries',
            'msgpack',
            'mssql',
            'mysql',
            'mysql_xdevapi',
            'mysqli',
            'ncurses',
            'newrelic',
            'oauth',
            'oci8',
            'odbc',
            'openssl',
            'parallel',
            'Parle',
            'pcntl',
            'pcov',
            'pcre',
            'pdflib',
            'PDO',
            'pdo_ibm',
            'pdo_mysql',
            'pdo_pgsql',
            'pdo_sqlite',
            'pgsql',
            'Phar',
            'phpdbg',
            'posix',
            'pspell',
            'pthreads',
            'radius',
            'rar',
            'rdkafka',
            'readline',
            'recode',
            'redis',
            'Reflection',
            'regex',
            'rpminfo',
            'rrd',
            -- "SaxonC",
            'session',
            'shmop',
            'SimpleXML',
            'snmp',
            'soap',
            'sockets',
            'sodium',
            'solr',
            'SPL',
            'SplType',
            'SQLite',
            'sqlite3',
            'sqlsrv',
            'ssh2',
            'standard',
            'stats',
            'stomp',
            'suhosin',
            'superglobals',
            'svm',
            'svn',
            'sybase',
            'sync',
            'sysvmsg',
            'sysvsem',
            'sysvshm',
            'tidy',
            'tokenizer',
            'uopz',
            'uuid',
            'uv',
            'v8js',
            'wddx',
            'win32service',
            'winbinder',
            'wincache',
            'wordpress',
            'xcache',
            'xdebug',
            'xhprof',
            'xlswriter',
            'xml',
            'xmlreader',
            'xmlrpc',
            'xmlwriter',
            'xsl',
            'xxtea',
            'yaf',
            'yaml',
            'yar',
            'zend',
            'Zend OPcache',
            'ZendCache',
            'ZendDebugger',
            'ZendUtils',
            'zip',
            'zlib',
            'zmq',
            'zookeeper',
            'zstd',
          },
          phpdoc = {
            textFormat = 'text',
            functionTemplate = {
              summary = '$1',
              tags = {
                '@param ${1:$SYMBOL_TYPE} $SYMBOL_NAME',
                '@return ${1:$SYMBOL_TYPE}',
                '@throws ${1:$SYMBOL_TYPE}',
              },
            },
          },
          files = { maxSize = 2500000 },
        },
      },
    }
  end,

  jsonls = function()
    return {
      on_new_config = function(new_config)
        new_config.settings.json.schemas = new_config.settings.json.schemas or {}
        vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
      end,
      settings = {
        json = {
          format = { enable = true },
          validate = { enable = true },
        },
      },
    }
  end,

  --- @see https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8
  lua_ls = function()
    return {
      settings = {
        Lua = {
          format = { enable = true },
          diagnostics = { enable = true },
          completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
          hint = {
            enable = true,
            arrayIndex = 'Disable',
            await = true,
            paramName = 'Disable',
            paramType = true,
            semicolon = 'Disable',
            setType = true,
          },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          misc = { parameters = { '--log-level=trace' } },
        },
      },
    }
  end,

  sqlls = function()
    return {
      root_dir = require('lspconfig').util.root_pattern '.git',
      single_file_support = false,
      on_new_config = function(new_config, new_rootdir)
        table.insert(new_config.cmd, '-config')
        table.insert(new_config.cmd, new_rootdir .. '/.config.yaml')
      end,
    }
  end,

  -- require('which-key').register({
  --   t = {
  --     name = 'Typescript', -- optional group name
  --     i = { ':TypescriptAddMissingImports<CR>', 'Add missing imports' },
  --     I = { ':TypescriptRemoveUnused<CR>', 'Remove unused imports' },
  --     o = { ':TypescriptOrganizeImports<CR>', 'Organize imports' },
  --     f = { ':TypescriptFixAll<CR>', 'Fix all issues' },
  --     r = { ':TypescriptRenameFile<CR>', 'Rename file' },
  --   },
  -- }, { prefix = '<leader>' })

  yamlls = {
    settings = {
      yaml = {
        customTags = {
          '!reference sequence', -- necessary for gitlab-ci.yaml files
        },
        schemaStore = { enable = true },
      },
    },
  },
}

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
return function(name)
  local config = name and servers[name] or {}
  if not config then return end

  if type(config) == 'function' then config = config() end

  local ok, cmp_nvim_lsp = mines.pcall(require, 'cmp_nvim_lsp')
  if ok then config.capabilities = cmp_nvim_lsp.default_capabilities() end


  config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, {
    textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
  })

  return config
end
