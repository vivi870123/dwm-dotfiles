-- stylua: ignore
return {
  snippet({ trig = 'v',   dscr = 'var' }, fmt('var {}', { i(1) })),
  snippet({ trig = 'l',   dscr = 'let' }, fmt('let {}', { i(1) })),
  snippet({ trig = 'req', dscr = 'require module' }, fmt('require "{}"', { i(1) })),
  snippet({ trig = 'af',  dscr = 'arrow function' }, fmt('({}) => {}', { i(1), i(0) })),
  snippet({ trig = 'afb',  dscr = 'arrow function block' }, fmt('({}) => {{{}}}', { i(1), i(0) })),
  snippet({ trig = 'fn', dacr ='named arrow function' }, fmt('const {} = ({}) => {{{}}}', { i(1), i(2), i(0) })),
  snippet({ trig = 'im', dscr = 'import module' }, fmt("import {} from '{}'", { i(1), i(2) })),

  -- --------
  -- -- React
  -- --------
  snippet({ trig = 'dp', dscr = 'destructuring of props' }, fmt("const {{ {} }} = this.props", { i(1)})),
  snippet({ trig = 'ds', dscr = 'destructuring of states' }, fmt("const {{ {} }} = this.states", { i(1)})),
  snippet({ trig = 'con', dscr = 'Adds a default constructor for the class that contains props as arguments' },
      fmt([[
      constructor (props) {{
          super(props)
          {}
      }}
      ]], { i(0) })),

  snippet({
      trig = 'conc',
      name = 'classConstructorContext',
      dscr = 'Adds a default constructor for the class that contains props and context as arguments',
  }, fmt([[
  constructor (props, context) {{
      super(props)
      {}
  }}
  ]], { i(0) })),

  snippet({
      trig = 'cwm',
      name = 'componentWillMount',
      dscr = 'Invoked once, both on the client and server, immediately before the initial rendering occurs',
  }, fmt("componentWillMount () {{{}}}", { i(0) })),

  snippet({
      trig = 'cdm',
      name = 'componentDidMount',
      dscr = 'Invoked once, only on the client (not on the server), immediately after the initial rendering occurs.',
  }, fmt("componentDidMount () {{{}}}", { i(0) })),

  snippet({
      trig = 'cwr',
      name = 'componentWillReceiveProps',
      dscr = 'Invoked when a component is receiving new props. This method is not called for the initial render.',
  }, fmt("componentWillReceiveProps (nextProps) {{{}}}", { i(0) })),

  snippet({
      trig = 'cgd',
      name = 'componentGetDerivedStateFromProps',
      dscr = 'Invoked after a component is instantiated as well as when it receives new props. It should return an object to update state, or null to indicate that the new props do not require any state updates.',
  }, fmt('static getDerivedStateFromProps(nextProps, prevState) {{{}}}', { i{0} })),

  snippet({
      trig = 'scup',
      name = 'shouldComponentUpdate',
      dscr = 'Invoked before rendering when new props or state are being received. ',
  }, fmt('shouldComponentUpdate (nextProps, nextState) {{{}}}', { i(0) })),

  snippet({
      trig = 'cwup',
      name = 'componentWillUpdate',
      dscr = 'Invoked immediately before rendering when new props or state are being received.',
  }, fmt('componentWillUpdate (nextProps, nextState) {{{}}}', { i(0) })),

  snippet({
      trig = 'cdup',
      name = 'componentDidUpdate',
      dscr = "Invoked immediately after the component's updates are flushed to the DOM.",
  }, fmt('componentWillUpdate (nextProps, nextState) {{{}}}', { i(0) })),

  snippet({
      trig = 'cwun',
      name = 'componentWillUnmount',
      dscr = "Invoked immediately before a component is unmounted from the DOM.",
  }, fmt('componentWillUnmount (nextProps, nextState) {{{}}}', { i(0) })),

  snippet({
      trig = 'ren',
      name = 'componentRender',
      dscr = "When called, it should examine this.props and this.state and return a single child element.",
  }, fmt([[
  render() {{
      return (
          <div>
              {}
          </div>
      )
  }}
  ]], { i(0) })),

  snippet({ trig = 'ssf', name = 'componentSetStateFunc', dscr = 'Performs a shallow merge of nextState into current state' },
      fmt('this.setState(state, props) => {{ return {} }})', { i(0) })),

  snippet({ trig = 'sst', name = 'componentSetStateObject', dscr = 'Performs a shallow merge of nextState into current state' },
      fmt("this.setState('{}')", { i(1) })),

  snippet({ trig = 'tp', name = 'componentProps', dscr = 'Access component\'s props', }, fmt('this.props.{}', { i(0) })),
  snippet({ trig = 'ts', name = 'componentState', dscr = 'Access component\'s state', }, fmt('this.state.{}', { i(0) })),

  -- React PropTypes
  snippet({ trig = 'rpt', name = 'propTypes', dscr = 'Creates empty propTypes declaration' },
      fmt("{}.proptypes = {{{}}}", { i(1), i(0) })
  ),

  snippet({ trig = 'pta', name = 'propTypeArray', dscr = 'Array prop type', }, { t('PropTypes.array,') }),
  snippet({ trig = 'ptar', name = 'propTypeArrayRequired', dscr = 'Array prop type required', }, { t('PropTypes.array.isRequired,') }),
  snippet({ trig = 'ptb', name = 'propTypeBool', dscr = 'Bool prop type', }, { t('PropTypes.bool,') }),
  snippet({ trig = 'ptbr', name = 'propTypeBoolRequired', dscr = 'Bool prop type required', }, { t('PropTypes.bool.isRequired,') }),
  snippet({ trig = 'ptf', name = 'propTypeFunc', dscr = 'Func prop type', }, { t('PropTypes.func,') }),
  snippet({ trig = 'ptfr', name = 'propTypeFunc', dscr = 'Func prop type required', }, { t('PropTypes.func.isRequired,') }),
  snippet({ trig = 'ptn', name = 'propTypeNumber', dscr = 'Number prop type', }, { t('PropTypes.number,') }),
  snippet({ trig = 'ptnr', name = 'propTypeNumber', dscr = 'Number prop type required', }, { t('PropTypes.number.isRequired,') }),
  snippet({ trig = 'pto', name = 'propTypeObject', dscr = 'Object prop type', }, { t('PropTypes.object,') }),
  snippet({ trig = 'ptor', name = 'propTypeObject', dscr = 'Object prop type required', }, { t('PropTypes.object.isRequired,') }),
  snippet({ trig = 'pts', name = 'propTypeString', dscr = 'String prop type', }, { t('PropTypes.string,') }),
  snippet({ trig = 'ptsr', name = 'propTypeString', dscr = 'String prop type required', }, { t('PropTypes.string.isRequired,') }),
  snippet({ trig = 'ptnd', name = 'propTypeNode', dscr = 'Anything that can be rendered: numbers, strings, elements or an array', }, { t('PropTypes.node,') }),
  snippet({ trig = 'ptndr', name = 'propTypeNode', dscr = 'Anything that can be rendered: numbers, strings, elements or an array required', }, { t('PropTypes.node.isRequired,') }),
  snippet({ trig = 'ptel', name = 'propTypeElement', dscr = 'Element prop type', }, { t('PropTypes.element,') }),
  snippet({ trig = 'ptelr', name = 'propTypeElement', dscr = 'Element prop type required', }, { t('PropTypes.element.isRequired,') }),
  snippet({ trig = 'pti', name = 'propTypeInstanceOf', dscr = 'Is an instance of a class prop type', }, { t('PropTypes.instanceOf('), i(0), t('),') }),
  snippet({ trig = 'ptir', name = 'propTypeInstanceOfRequired', dscr = 'Is an instance of a class prop type required', }, { t('PropTypes.instanceOf('), i(0), t(').isRequired,') }),
  snippet({ trig = 'pte', name = 'propTypeEnum', dscr = 'Prop type limited to specific values by treating it as an enum' }, { t("PropTypes.oneOf(['"), i(0), t("']),") }),
  snippet({ trig = 'pter', name = 'propTypeEnum', dscr = 'Prop type limited to specific values by treating it as an enum required' }, { t("PropTypes.oneOf(['"), i(0), t("').isRequired,") }),
  snippet({ trig = 'ptet', name = 'propTypeOneOfType', dscr = 'An object that could be one of many types' }, { t({'PropTypes.oneOfType([', ''}), t('\t'), i(0), t({'', ''}), t(']),') }),
  snippet({ trig = 'ptetr', name = 'propTypeOneOfType', dscr = 'An object that could be one of many types required' }, { t({'PropTypes.oneOfType([', ''}), t('\t'), i(0), t({'', ''}), t(']).isRequired,') }),
  snippet({ trig = 'ptao', name = 'propTypeArrayOf', dscr = 'An array of a certain type' }, { t('PropTypes.arrayOf('), i(0), t('),') }),
  snippet({ trig = 'ptaor', name = 'propTypeArrayOfRequired', dscr = 'An object with property values of a certain type' }, { t('PropTypes.arrayOf('), i(0), t(').isRequired,') }),
}

