#!/usr/bin/python3.6

import requests
from requests.auth import HTTPBasicAuth

class HTTP:
    def __init__(self, base_api_url=None, login=None, headers={}):
        # Initialize and set (if provided) the auth for the user
        self._auth = None
        if login is not None:
            self._auth = HTTPBasicAuth(login[0], login[1])

        self._base_api_url = base_api_url

        self._headers = headers

    def set_auth(self, login):
        self._auth = HTTPBasicAuth(login[0], login[1])

    def _request(self, method, url, payload=None, headers=None, params=None, json=None):
        if headers is None:
            headers = self._headers

        response = requests.request(
            method=method,
            url=url,
            auth=self._auth,
            data=payload,
            headers=headers,
            params=params,
            json=json,
        )

        # TODO: Validate response

        return response

    def get_all_orgs(self):
        # Set the api endpoint to hit to get a list of orgs
        api_endpt = "organizations"
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def get_org_by_id(self, org_id):
        # Set the api endpoint to hit to get the org
        api_endpt = "organizations/" + str(org_id)
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def get_all_stores(self):
        # Set the api endpoint to hit to get a list of stores
        api_endpt = "stores"
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def get_store_by_id(self, store_id):
        # Set the api endpoint to hit to get the store
        api_endpt = "stores/" + str(store_id)
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def get_all_robots(self):
        # Set the api endpoint to hit to get a list robots
        api_endpt = "robots"
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def get_robot_by_id(self, robot_id):
        # Set the api endpoint to hit to get the robot
        api_endpt = "robots/" + str(robot_id)
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def get_play_execution_by_id(self, play_execution_id):
        # Set the api endpoint to hit to get the play execution information
        api_endpt = "play_executions/" + str(play_execution_id)
        target_url = self._base_api_url + api_endpt

        # Save the response
        response = self._request("GET", target_url, None, None, None, None)

        # Return the response
        return response

    def open_robot_vpn(self, robot_id):
        # Set the api endpoint to hit to open the vpn on the robot
        api_endpt = "robots/" + str(robot_id) + "/commands"
        target_url = self._base_api_url + api_endpt

        payload = {"command_type": "open_vpn", "parameters": {}}

        # Save the response
        response = self._request("POST", target_url, payload, None, None, None)

        # Return the response
        return response

    def close_robot_vpn(self, robot_id):
        # Set the api endpoint to hit to close the vpn on the robot
        api_endpt = "robots/" + str(robot_id) + "/commands"
        target_url = self._base_api_url + api_endpt

        payload = {"command_type": "close_vpn", "parameters": {}}

        # Save the response
        response = self._request("POST", target_url, payload, None, None, None)

        # Return the response
        return response

    def power_control_robot(self, robot_id, action="off", force=True, object_id="robot", reset_delay_seconds="30",
                            wait_before_cancel="30", wait_before_forced_shutdown="120"):
        # Set the api endpoint to hit to send the power control command to for a given robot
        api_endpt = "robots/" + str(robot_id) + "/commands"
        target_url = self._base_api_url + api_endpt

        payload = {"command_type": "power_control",
                   "parameters": {
                       "action": action,
                       "force": force,
                       "object_id": object_id,
                       "reset_delay_seconds": reset_delay_seconds,
                       "wait_before_cancel": wait_before_cancel,
                       "wait_before_forced_shutdown": wait_before_forced_shutdown
                   }}

        # Save the response
        response = self._request("POST", target_url, payload, None, None, None)

        # Return the response
        return response
