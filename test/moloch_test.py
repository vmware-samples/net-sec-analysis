#!/usr/bin/python
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
''' IDS Apps test: Suricata script '''
import time
import sys
from sys import argv
import logging
import re
import argparse
import requests
from requests import RequestException
from requests.auth import HTTPDigestAuth

def formatted_logger(message, lev):
    ''' Formatted Logger '''
    logging.basicConfig(
        format='%(asctime)s %(levelname)-8s %(message)s',
        level=logging.DEBUG,
        datefmt='%Y-%m-%d %H:%M:%S')
    if 'debug' in lev or 'DEBUG' in lev:
        logging.debug(message)
    elif 'error' in lev or 'ERROR' in lev:
        logging.error(message)
    elif 'info' in lev or 'INFO' in lev:
        logging.info(message)
    elif 'warn' in lev or 'WARN' in lev:
        logging.warning(message)


def my_args(my_argv):
    ''' Function to parse args! returns args'''
    parser = argparse.ArgumentParser(description="Prepare for IDS test")
    parser.add_argument("--http_test_host", "-ht", default="google.com",\
        help="Specify HTTP Host to send get request")
    parser.add_argument("--moloch_url", "-molochurl", default="localhost:8005",\
        help="Specify moloch viewer url")
    parser.add_argument("--moloch_user", "-molochuser", default="admin",\
        help="Specify moloch user")
    parser.add_argument("--moloch_password", "-molochpassword", default="QkCuZA34LT",\
        help="Specify moloch password")
    args = parser.parse_args(my_argv[1:])
    return args

def main():
    ''' Main Function '''
    args = my_args(argv)
    my_host = re.split('/', args.http_test_host)
    my_moloch_search_url = re.split('/', args.moloch_url)
    moloch_search_url = 'https://' + my_moloch_search_url[-1]
    moloch_search_url += '/sessions.json?graphType=lpHisto&seriesType=bars&date=-1&expression=host.http%3D%3D' 
    moloch_search_url += my_host[-1] 
    moloch_search_url += '%2a'
    
    retries = 60
    for retry in range(retries):
        try:
            req = requests.get(moloch_search_url, auth=HTTPDigestAuth(args.moloch_user, args.moloch_password), verify=False)
            if req.status_code == 200:
                response = req.json()
                if response['recordsFiltered'] > 0:
                    message = "Test Passed! Search result: "+str(response['recordsFiltered'])
                    formatted_logger(message, 'info')
                    sys.exit(0)
                else:
                    message = "Try#" + str(retry)
                    message += " -" + "Test Failed! Search result: "
                    message += str(response['recordsFiltered'])
                    formatted_logger(message, 'info')
            else:
                    message = "Try#" + str(retry)
                    message += " -" + "Moloch search status code: "
                    message += str(req.status_code)
                    formatted_logger(message, 'info')
        except RequestException as error:
            formatted_logger(error, 'error')
            sys.exit(1)
        time.sleep(30)
    formatted_logger("Max retries exceeded", 'error')
    sys.exit(1)

if __name__ == "__main__":
    main()
