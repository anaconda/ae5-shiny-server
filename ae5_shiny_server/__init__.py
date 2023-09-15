import sys
import os
import shutil

from argparse import ArgumentParser
from jinja2 import Template

__version__ = '0.0.3'
TOOL_DIR = '/tools/shiny-server'
CONF_FILENAME = 'shiny-server.conf'
CONF_TEMPLATE_FILENAME = 'shiny-server.conf.jinja2'
SERVER_BINARY = os.path.join(TOOL_DIR, 'bin', 'shiny-server')

def main():
    parser = ArgumentParser(prog="shiny_server",
                            description="Utility to run shiny server in AE5")
    parser.add_argument('--conf', action='store', default=None, type=str,
                        help=('Path to server config file to use directly. '
                              'Overrides all other options'))
    parser.add_argument('--conf-template', action='store',
                        default=os.path.join(TOOL_DIR,  CONF_TEMPLATE_FILENAME), type=str,
                        help='Path to server config template file')
    parser.add_argument('--conf-render-dir', action='store',
                        default='/opt/continuum/project/shiny-server.conf', type=str,
                        help=('Path to the server config template file '
                              'rendered from the template'))
    parser.add_argument('--disable-execution', action='store_true',
                       help='Print command invocation instead of running shiny server')
    parser.add_argument('--version', action='store_true')
    parser.add_argument('--verbose', action='store_true')
    # TEMPLATING OPTIONS MAPPING TO CONF.JINJA2
    parser.add_argument('--site-dir', action='store', default=None, type=str,
                        help='Directory of shiny apps to serve')
    parser.add_argument('--log-dir', action='store', default=None, type=str,
                        help='Directory to store shiny server logs')
    parser.add_argument('--bookmark-state-dir', action='store', default=None, type=str,
                        help='Location of the shiny bookmark state directory')

    args = parser.parse_args(sys.argv[1:])

    if args.version:
        print(f'VERSION: {__version__}')

    conf_path = None
    if args.conf is None:
        templated_conf = render_template(os.path.abspath(args.conf_template), args)

        if args.verbose:
            print('-- RENDERED TEMPLATE --\n')
            print(templated_conf)

        # print(templated_conf) add verbose flag?
        conf_path = args.conf_render_dir
        with open(conf_path, 'w') as f:
            f.write(templated_conf)
    else:
        if not os.path.exists(args.conf):
            raise IOError(f'Cannot find conf file {args.conf}')

        conf_path = args.conf

    if args.verbose:
        print(f"Using configuration file {conf_path}")

    if not args.disable_execution:
        shutil.copytree('shiny', './data/shiny') # IMPROVE
        os.system(f'{SERVER_BINARY} {conf_path}')
    else:
        print('-- EXECUTION COMMAND --\n')
        print(f'{SERVER_BINARY} {conf_path}')

def render_template(template_filepath, args): # '/opt/continuum/data/shiny'
    # Only template in if not None - assume template contain suitable defaults
    ignored_vars = ['conf', 'conf_template']
    if os.path.exists(template_filepath):
        with open(template_filepath) as file_:
            template = Template(file_.read())

        variables = dict(username=os.environ["USER"])
        variables.update({k:v for k,v in vars(args).items()
                          if (k not in ignored_vars) and (v is not None)})
        templated = template.render(variables)
        return templated
    else:
        raise IOError(f'Template file {template_filepath} not found')



if __name__ == '__main__':
    main()
