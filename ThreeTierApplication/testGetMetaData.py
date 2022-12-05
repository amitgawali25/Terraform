import unittest
from  getMetaData import buildJsonByKey



class TestGetMetaData(unittest.TestCase):

    def test_instance_type(self):
        self.assertEqual(buildJsonByKey('instance-type'), ['t2.micro'], "Should be ['t2.micro']")

    def test_ava_zone(self):
        self.assertEqual(buildJsonByKey('availability-zone'), ['us-east-1a'], "Should be ['us-east-1a']")

    def test_local_ipv4(self):
        self.assertEqual(buildJsonByKey('local-ipv4'), ['10.0.0.4'], "Should be ['10.0.0.4']")

    def test_az_id(self):
        self.assertEqual(buildJsonByKey('availability-zone-id'), ['use1-az4'], "Should be ['use1-az4']")

    def test_region(self):
        self.assertEqual(buildJsonByKey('region'), ['us-east-1'], "Should be ['us-east-1']")

    def test_target_lifecycle_state(self):
        self.assertEqual(buildJsonByKey('target-lifecycle-state'), ['InService'], "Should be ['InService']")

    def test_vpc_ipv4_cidr_block(self):
        self.assertEqual(buildJsonByKey('vpc-ipv4-cidr-block'), ['10.0.0.0/16'], "Should be ['10.0.0.0/16']")


if __name__ == '__main__':
    unittest.main()