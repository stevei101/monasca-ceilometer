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
source .tox/py27/bin/activate
./tools/send_test_data.py --count 1 --resources_count 1 --topic notification.info
"""
import argparse
import datetime
import json
import random
import uuid

# import make_test_data_draft as make_test_data
from oslo_context import context

from ceilometer import messaging
from ceilometer import service


def make_test_data(name, meter_type, unit, volume, random_min,
                   random_max, user_id, project_id, resource_id,
                   resource_list, start, end, interval,
                   resource_metadata=None, source='artificial'):
    resource_metadata = resource_metadata or {}
    # Compute start and end timestamps for the new data.
    if isinstance(start, datetime.datetime):
        timestamp = start
    else:
        timestamp = timeutils.parse_strtime(start)

    if not isinstance(end, datetime.datetime):
        end = timeutils.parse_strtime(end)

    increment = datetime.timedelta(minutes=interval)

    print('Adding new events for meter %s.' % (name))
    # Generate events
    n = 0
    total_volume = volume
    while timestamp <= end:
        if (random_min >= 0 and random_max >= 0):
            # If there is a random element defined, we will add it to
            # user given volume.
            if isinstance(random_min, int) and isinstance(random_max, int):
                total_volume += random.randint(random_min, random_max)
            else:
                total_volume += random.uniform(random_min, random_max)

        c = sample.Sample(name=name,
                          type=meter_type,
                          unit=unit,
                          volume=total_volume,
                          user_id=user_id,
                          project_id=project_id,
                          resource_id=resource_list[random.randint(0,
                                                    len(resource_list) - 1)],
                          timestamp=timestamp.isoformat(),
                          resource_metadata=resource_metadata,
                          source=source,
                          )
        data = utils.meter_message_from_counter(
            c, cfg.CONF.publisher.telemetry_secret)
        # data = utils.meter_message_from_counter(
        #      c, cfg.CONF.publisher.metering_secret)

        yield data
        n += 1
        timestamp = timestamp + increment

        if (meter_type == 'gauge' or meter_type == 'delta'):
            # For delta and gauge, we don't want to increase the value
            # in time by random element. So we always set it back to
            # volume.
            total_volume = volume

    print('Added %d new events for meter %s.' % (n, name))


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
    for sample in make_test_data(**make_data_args.__dict__):
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

    """
    # these are from make_test_data.py
    parser = argparse.ArgumentParser(
        description='generate metering data',
    )
    parser.add_argument(
        '--interval',
        default=10,
        type=int,
        help='The period between events, in minutes.',
    )
    parser.add_argument(
        '--start',
        default=31,
        help='Number of days to be stepped back from now or date in the past ('
             '"YYYY-MM-DDTHH:MM:SS" format) to define timestamps start range.',
    )
    parser.add_argument(
        '--end',
        type=int,
        default=2,
        help='Number of days to be stepped forward from now or date in the '
             'future ("YYYY-MM-DDTHH:MM:SS" format) to define timestamps end '
             'range.',
    )
    parser.add_argument(
        '--type',
        choices=('gauge', 'cumulative'),
        default='gauge',
        dest='meter_type',
        help='Counter type.',
    )
    parser.add_argument(
        '--unit',
        default=None,
        help='Counter unit.',
    )
    parser.add_argument(
        '--project',
        dest='project_id',
        help='Project id of owner.',
    )
    parser.add_argument(
        '--user',
        dest='user_id',
        help='User id of owner.',
    )
    parser.add_argument(
        '--random_min',
        help='The random min border of amount for added to given volume.',
        type=int,
        default=0,
    )
    parser.add_argument(
        '--random_max',
        help='The random max border of amount for added to given volume.',
        type=int,
        default=0,
    )
    parser.add_argument(
        '--resource',
        dest='resource_id',
        help='The resource id for the meter data.',
    )
    parser.add_argument(
        '--counter',
        default='instance',
        dest='name',
        help='The counter name for the meter data.',
    )
    parser.add_argument(
        '--volume',
        help='The amount to attach to the meter.',
        type=int,
        default=1,
    )
    return parser

    """

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
        default='notification.info'
    )
    parser.add_argument(
        '--samples-count',
        dest='samples_count',
        type=int,
        default=1
    )
    parser.add_argument(
        '--resources-count',
        dest='resources_count',
        type=int,
        default=1
    )
    """
    parser.add_argument(
        '--result-directory',
        dest='result_dir',
        default='/tmp'
    )
    """
    return parser

# we would not need to store files
# the default should only be one resource


def main():
    args = get_parser().parse_known_args()[0]
    # make_data_args = make_test_data.get_parser().parse_known_args()[0]
    rpc_client = get_rpc_client(args.config_file)
    # result_dir = args.result_dir
    del args.config_file
    # del args.result_dir

    """
    resource_writes = generate_data(rpc_client, make_data_args,
                                    **args.__dict__)
    result_file = "%s/sample-by-resource-%s" % (result_dir,
                                                random.getrandbits(32))
    with open(result_file, 'w') as f:
        f.write(json.dumps(resource_writes))
    return result_file
    """

if __name__ == '__main__':
    main()
