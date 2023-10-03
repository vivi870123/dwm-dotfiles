local util = require 'plugins.snippets.utils'
local copy = util.copy

-- visibility allows to reuse it pasing the first option to show for the snippet
local function visibility(_, _, _, initial_text)
  local possibles = { 'private', 'public', 'protected' }
  local options = {}

  for _, value in pairs(possibles) do
    if value == initial_text then
      table.insert(options, 1, t(value .. ' '))
    else
      table.insert(options, t(value .. ' '))
    end
  end

  return sn(nil, { c(1, options) })
end

-- ls.add_snippets('php', {
-- }, {
--   type = 'autosnippets',
--   key = 'all_auto',
-- }, { key = 'php_init' })


-- TODO: Add pcall snippet and use TS to parse saved function and separete the funcion name and the args
-- stylua: ignore
return {
    -- variable
    snippet(
        { trig = 'v', name = 'php', dscr = 'variable' },
        fmt("private ${} = {};", { i(1, 'key'), i(0, 'value') })
    ),
    snippet(
        { trig = 'this', name = 'php', dscr = '$this->name' },
        fmt("$this->{}", { i(1, 'name') })
    ),
    snippet(
        { trig = '.', name = 'php', dscr = '->name' },
        fmt("->{}", { i(1, 'name') })
    ),
    snippet({ trig = 'ret', name = 'php', dscr = 'return' },
        fmt("return {};", { i(1) })
    ),

    snippet({ trig = 'rett', name = 'php', dscr = 'return true' }, {
        t('return true;'),
    }),

    snippet({ trig = 'retf', name = 'php', dscr = 'return false' }, {
        t('return false;'),
    }),

    snippet({ trig = 'retn', name = 'php', dscr = 'return null' }, {
        t('return null;'),
    }),

    snippet({ trig = 'reta', name = 'php', dscr = 'return array' }, {
        t('return ['), i(1), t('];')
    }),

    snippet({ trig = 'reta', name = 'php', dscr = 'return array' },
        fmt("return [{}];", { i(1) })
    ),

    -- __construct
    snippet('_c', fmt([[
    {} function __construct({})
    {{
        {}
    }}
    ]], { i(1, 'public'), i(2), i(0) })),

    -- function
    snippet("met", {
        d(1, visibility, {}, "public"),
        t("function "),
        i(2, "name"),
        t("("),
        i(3, "$arg"),
        t(")"),
        c(4, {
            sn(nil, {
                t(': '),
                i(1, "void"),
            }),
            t(""),
        }),
        t({"", "{", ""}),
        t("\t"), i(0, ""),
        t({"", "}"})
    }),

    snippet("pmet", {
        d(1, visibility, {}, "private"),
        t("function "),
        i(2, "name"),
        t("("),
        i(3, "$arg"),
        t(")"),
        c(4, {
            sn(nil, {
                t(': '),
                i(1, "void"),
            }),
            t(""),
        }),
        t({"", "{", ""}),
        t("\t"), i(0, ""),
        t({"", "}"})
    }),

    -- Route
    snippet("ro", {
        t("Route::"),
        c(1, {
            t("get"),
            t("post"),
            t("put"),
            t("view"),
        }),
        t("('"),
        i(2, "uri"),
        t("', "),
        c(3, {
            sn(nil, {
                t({'function () {', '\t'}),
                i(1, ''),
                t({'', '});'}),
            }),
            sn(nil, {
                t('['),
                i(1, 'Controller'),
                t("::class, '"),
                i(2, 'method'),
                t("']);"),
            })
        }),
    }),

    snippet({ trig = 'pu', name = 'phpunit', dscr = 'testcase function' },
        fmt([[
        public function test_it_{}()
        {{
            {}
        }}
        ]], {i(1), i(2)}
        )),

    snippet({ trig = 'do', dscr = 'do while loop', },
        fmt([[
        do {{
            {}
        }} while({});
        ]], { i(0), i(1) }
        )),

    snippet({ trig = 'while', dscr = 'while loop', },
        fmt([[
        while (${}) {{
            {}
        }};
        ]], { i(1), i(0) }
        )),

    snippet({ trig = 'if', dscr = 'if condition', },
        fmt([[
        if(${}) {{
            {}
        }}
        ]], { i(1), i(2) }
        )),

    snippet({ trig = 'ifn', dscr = 'if null condition', },
        fmt([[if (null === ${}) {{
            {}
        }}
        ]], { i(1), i(2) }
    )),

    snippet({ trig = 'ift', dscr = 'if true condition', },
        fmt([[if (${} === true) {{
            {}
        }}
        ]], { i(1), i(2) }
    )),

    snippet({ trig = 'iff', dscr = 'if false condition', },
        fmt([[if (${} === false) {{
            {}
        }}
        ]], { i(1), i(2) }
    )),

    snippet({ trig = 'ife', dscr = 'if else condition', }, {
        t('if ($'), i(1), t({') {', ''}),
        t("\t"), i(0, ""), t({'', ''}),
        t({'} else {', ''}),
        t("\t"), i(2, ""), t({'', ''}),
        t('}'),
    }),

    snippet({ trig = 'else', dscr = 'else block', }, {
        t({'else {'}),
        t("\t"), i(0, ""), t({'', ''}),
        t('}')
    }),

    snippet({ trig = 'for', dscr = 'for loop' }, {
        t({'for ($'}), i(1, 'i'), t('='), i(2, '0'), t('; $'), f(copy, 1), t(' < '), i(3, '10'), t('; $'), f(copy, 1), t({'++) {', ''}),
        t("\t"), i(0, ""), t({'', ''}),
        t('}')
    }),

    snippet({ trig = 'foreach', dscr = 'foreach loop', }, {
        t('foreach ($'), i(1, 'condition'), t({') {', ''}),
        t("\t"), i(0, ""), t({'', ''}),
        t('}')
    }),


    snippet({ trig = 'switch', dscr = 'switch block', }, {
        t('switch ($'), i(1), t({') {', ''}),
        t('\tcase ($'), i(2), t({':', ''}),
        t('\t\t'), i(3), t({'', ''}),
        t({'\t\tbreak;', ''}),
        t('\t'), i(0),
        t({'default:', ''}),
        t('\t\t'), i(4), t({'', ''}),
        t('}'),
    }),

    snippet({ trig = 'case', dscr = 'case block', }, {
        t('case ($'), i(1), t({') {', ''}),
        t("\t"), i(0, ""), t({'', ''}),
        t('}')
    }),

    -- Route
    snippet({ trig = 'route', name = 'laravel', dscr = 'route method', }, {
        t("Route::"),
        c(1, { t("get"), t("post"), t("put"), t("view") }),
        t("('"),
        i(2, "uri"),
        t("', "),
        c(3, {
            sn(nil, {
                t({'function () {', '\t'}), i(1, ''), t({'', '});'}) }),
            sn(nil, {
                t('['),
                i(1, 'Controller'), t("::class, '"), i(2, 'method'), t("']);"),
            })
        }),
    }),

    snippet({ trig = 'dd', name = 'laravel', dscr = 'die and dump', }, {
        t('dd('), i(1), t({')'}), i(0)
    }),

    snippet({ trig = 'da', name = 'laravel', dscr = 'die and dump as array', }, {
        t('dd($'), i(1), t({'->toArray())'}), i(0)
    }),

    snippet({ trig = 'fill', name = 'laravel', dscr = 'Model fillable prop', }, {
        t({'public $fillable = [', ''}),
        t('\t'), i(1), t({'', ''}),
        t('];')
    }),

    snippet({ trig = 'state', name = 'laravel', dscr = 'factory state', }, {
        t('public function '), i(1), t({'()', ''}),
        t({'\t return $this->state(function (array $attributes) {', ''}),
        t({'\t\treturn [', ''}),
        t({'\t\t\t'}), i(2), t({'', ''}),
        t({'\t\t];', ''}),
        t({'\t});', ''}),
        t('}')
    }),

},
{
  snippet({ trig = 'vv', name = 'php', dscr = '$' }, fmt('${}', { i(1) })),
  snippet(
    { trig = 't.', name = 'php', dscr = '$this->name' },
    fmt("$this->{}", { i(1, 'name') })
  ),
}
