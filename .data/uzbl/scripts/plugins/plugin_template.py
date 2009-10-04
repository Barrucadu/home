'''Plugin template.'''

# A list of functions this plugin exports to be used via uzbl object.
__export__ = ['myplugin_function',]

# Holds the per-instance data dict.
UZBLS = {}

# The default instance dict.
DEFAULTS = {}


def add_instance(uzbl, pid):
    '''Add a new instance with default config options.'''

    UZBLS[uzbl] = dict(DEFAULTS)


def del_instance(uzbl, pid):
    '''Delete data stored for an instance.'''

    if uzbl in UZBLS:
        del UZBLS[uzbl]


def get_myplugin_dict(uzbl):
    '''Get data stored for an instance.'''

    if uzbl not in UZBLS:
        add_instance(uzbl)

    return UZBLS[uzbl]


def myplugin_function(uzbl, *args, **kargs):
    '''Custom plugin function which is exported by the __export__ list at the
    top of the file for use by other functions/callbacks.'''

    print "My plugin function arguments:", args, kargs

    # Get the per-instance data object.
    data = get_myplugin_dict(uzbl)

    # Function logic goes here.


def myplugin_event_parser(uzbl, args):
    '''Parses MYPLUGIN_EVENT raised by uzbl or another plugin.'''

    print "Got MYPLUGIN_EVENT with arguments: %r" % args

    # Parsing logic goes here.


def init(uzbl):
    '''The main function of the plugin which is used to attach all the event
    hooks that are going to be used throughout the plugins life. This function
    is called each time a UzblInstance() object is created in the event
    manager.'''

    connects = {
      # EVENT_NAME       HANDLER_FUNCTION
      'INSTANCE_START':  add_instance,
      'INSTANCE_EXIT':   del_instance,
      'MYPLUGIN_EVENT':  myplugin_event_parser,
    }

    for (event, handler) in connects.items():
        uzbl.connect(event, handler)
