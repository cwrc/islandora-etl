""" unitest tests
"""
import sys
import os
import collections
import unittest
import xml.etree.cElementTree as etree

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import islandora7_export as i7_export


class TestMetadataPackageBuilder(unittest.TestCase):

    def setUp(self):
        self.pid = 'xxxx-xxxx-xxxx-xxxx'
        self.object_metadata = {
            'pid': self.pid,
            'label': 'label',
            'owner': 'owner',
            'models': 'models',
            'created': 'created',
            'modified': 'modified'
        }

    def test_init(self):
        (self.xml_root, self.xml_media, self.xml_metadata) = i7_export.metadata_combined_init(self.pid, self.object_metadata)
        self.assertEqual(self.xml_root.attrib['pid'], self.object_metadata['pid'])
        self.assertEqual(self.xml_root.attrib['label'], self.object_metadata['label'])
        self.assertEqual(self.xml_root.attrib['owner'], self.object_metadata['owner'])
        self.assertEqual(self.xml_root.attrib['created'], self.object_metadata['created'])
        self.assertEqual(self.xml_root.attrib['modified'], self.object_metadata['modified'])

    def test_media_file_path(self):
        filepath = 'asdf'
        ds_id = 'ASDF'
        (self.xml_root, self.xml_media, self.xml_metadata) = i7_export.metadata_combined_init(self.pid, self.object_metadata)
        i7_export.metadata_record_filepath(self.xml_media, filepath, ds_id)
        # etree.ElementTree(self.xml_root).write(sys.stdout.buffer, encoding='utf-8', xml_declaration=True, method="xml")
        self.assertEqual(self.xml_root.findall('./media_exports/media[1]')[0].attrib['filepath'], filepath)
        self.assertEqual(self.xml_root.findall('./media_exports/media[1]')[0].attrib['ds_id'], ds_id)

    def test_metadata_inclusion(self):
        ds_id = 'MODS'
        ds_content = '<a>asdf</a>'
        (xml_root, xml_media, xml_metadata) = i7_export.metadata_combined_init(self.pid, self.object_metadata)
        i7_export.metadata_combined_add_datastream(xml_metadata, ds_id, ds_content)
        # etree.ElementTree(xml_root).write(sys.stdout.buffer, encoding='utf-8', xml_declaration=True, method="xml")
        self.assertEqual(xml_root.findall('./resource_metadata/a[1]')[0].text, 'asdf')

    def test_metadata_exclusion(self):
        ds_id = 'NOT_IN_INCLUSION_LIST'
        ds_content = '<a>asdf</a>'
        (xml_root, xml_media, xml_metadata) = i7_export.metadata_combined_init(self.pid, self.object_metadata)
        i7_export.metadata_combined_add_datastream(xml_metadata, ds_id, ds_content)
        # etree.ElementTree(xml_root).write(sys.stdout.buffer, encoding='utf-8', xml_declaration=True, method="xml")
        self.assertFalse(xml_root.findall('./resource_metadata/a[1]'))



if __name__ == '__main__':
    unittest.main()