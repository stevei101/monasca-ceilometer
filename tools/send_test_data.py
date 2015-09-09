#!/usr/bin/env python
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

"""Command line tool for sending test data for Ceilometer via oslo.messaging.
Usage:
Send messages with samples generated by make_test_data
cd monasca-ceilometer/tools
/usr/bin/python send_test_data.py \
    --count 1 --resources_count 1 --topic notification.info
"""
import argparse
import datetime
import json
import random
import uuid

import make_test_data2 as make_test_data
from oslo_context import context

from ceilometer import messaging
from ceilometer import service


def send_batch(rpc_client, topic, batch):
    rpc_client.prepare(topic=topic).cast(context.RequestContext(),
                                         'record_metering_data', data=batch)


def get_rpc_client(config_file):
    service.prepare_service(argv=['/', '--config-file', config_file])
    transport = messaging.get_transport()
    rpc_client = messaging.get_rpc_client(transport, version='1.0')
    return rpc_client


def generate_data(rpc_client, make_data_args, samples_count,
                  batch_size, resources_count, topic):
    make_data_args.interval = 1
    make_data_args.start = (datetime.datetime.utcnow() -
                            datetime.timedelta(minutes=samples_count))
    make_data_args.end = datetime.datetime.utcnow()

    resource_list = [str(uuid.uuid4()) for _ in xrange(resources_count)]
    resource_samples = {resource: 0 for resource in resource_list}
    make_data_args.resource_list = resource_list
    batch = []
    count = 0
    for sample in make_test_data.make_test_data(**make_data_args.__dict__):
        count += 1
        resource_samples[sample['resource_id']] += 1
        batch.append(sample)
        if len(batch) == batch_size:
            send_batch(rpc_client, topic, batch)
            batch = []
        if count == samples_count:
            send_batch(rpc_client, topic, batch)
            return resource_samples
    send_batch(rpc_client, topic, batch)
    return resource_samples


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--batch-size',
        dest='batch_size',
        type=int,
        default=100
    )
    parser.add_argument(
        '--config-file',
        default='/etc/ceilometer/ceilometer.conf'
    )
    parser.add_argument(
        '--topic',
        default='perfmetering'
    )
    parser.add_argument(
        '--samples-count',
        dest='samples_count',
        type=int,
        default=1000
    )
    parser.add_argument(
        '--resources-count',
        dest='resources_count',
        type=int,
        default=100
    )
    parser.add_argument(
        '--result-directory',
        dest='result_dir',
        default='/tmp'
    )
    return parser


def main():
    args = get_parser().parse_known_args()[0]
    make_data_args = make_test_data.get_parser().parse_known_args()[0]
    rpc_client = get_rpc_client(args.config_file)
    result_dir = args.result_dir
    del args.config_file
    del args.result_dir

    resource_writes = generate_data(rpc_client, make_data_args,
                                    **args.__dict__)
    result_file = "%s/sample-by-resource-%s" % (result_dir,
                                                random.getrandbits(32))
    with open(result_file, 'w') as f:
        f.write(json.dumps(resource_writes))
    return result_file


if __name__ == '__main__':
    main()
