from __future__ import print_function
import httplib2
import os

from apiclient import discovery
import oauth2client
from oauth2client import client
from oauth2client import tools

import codeforces_events

try:
    import argparse
    flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
except ImportError:
    flags = None

SCOPES = 'https://www.googleapis.com/auth/calendar'
CLIENT_SECRET_FILE = 'credentials.json'
APPLICATION_NAME = 'Code to Calender'


def get_credentials():
    """Gets valid user credentials from storage.

    If nothing has been stored, or if the stored credentials are invalid,
    the OAuth2 flow is completed to obtain the new credentials.

    Returns:
        Credentials, the obtained credential.
    """
    home_dir = os.path.expanduser('~')
    credential_dir = os.path.join(home_dir, '.credentials')
    if not os.path.exists(credential_dir):
        os.makedirs(credential_dir)
    credential_path = os.path.join(credential_dir,
                                   'calendar-python-quickstart.json')

    store = oauth2client.file.Storage(credential_path)
    credentials = store.get()
    if not credentials or credentials.invalid:
        flow = client.flow_from_clientsecrets(CLIENT_SECRET_FILE, SCOPES)
        flow.user_agent = APPLICATION_NAME
        if flags:
            credentials = tools.run_flow(flow, store, flags)
        else: # Needed only for compatibility with Python 2.6
            credentials = tools.run(flow, store)
        print('Storing credentials to ' + credential_path)
    return credentials


def main():
    """Shows basic usage of the Google Calendar API.

    Creates a Google Calendar API service object and outputs a list of the next
    10 events on the user's calendar.
    """
    credentials = get_credentials()
    http = credentials.authorize(httplib2.Http())
    service = discovery.build('calendar', 'v3', http=http)

    #events = codeforces_events.get_events()
    events = []
    new_event = {
                  'summary': 'Preetham',
                  'location': 'Raipur, India',
                  'description': 'Preetham Project....',
                  'start': {
                    'dateTime': '2018-12-23T13:35:00+00:00',
                    'timeZone': 'Asia/Kolkata'
                  },
                  'end': {
                    'dateTime': '2018-12-23T15:35:00+00:00',
                    'timeZone': 'Asia/Kolkata'
                  },
                  'reminders': {
                    'useDefault': False,
                    'overrides': [
                      {'method': 'popup', 'minutes': 15},
                    ],
                  },
                }
    events.append(new_event)

    for new_event in events:
        event = service.events().insert(calendarId='primary', body=new_event).execute()
        print('Event created: %s' % (event.get('htmlLink')))


if __name__ == '__main__':
    main()