/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.commons.imaging.formats.jpeg.iptc;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.imaging.ImageReadException;
import org.apache.commons.imaging.ImageWriteException;
import org.apache.commons.imaging.ImagingConstants;
import org.apache.commons.imaging.common.bytesource.ByteSource;
import org.apache.commons.imaging.common.bytesource.ByteSourceFile;
import org.apache.commons.imaging.formats.jpeg.JpegImageParser;
import org.apache.commons.imaging.formats.jpeg.JpegPhotoshopMetadata;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

@RunWith(Parameterized.class)
public class IptcUpdateTest extends IptcBaseTest {
    private final File imageFile;

    @Parameterized.Parameters
    public static Collection<File> data() throws Exception {
        return getImagesWithIptcData();
    }

    public IptcUpdateTest(final File imageFile) {
        this.imageFile = imageFile;
    }

    /*
     * Remove all Photoshop IPTC data from a JPEG file.
     */
    @Test
    public void testRemove() throws Exception {
        final ByteSource byteSource = new ByteSourceFile(imageFile);

        final Map<String, Object> params = new HashMap<>();
        final boolean ignoreImageData = isPhilHarveyTestImage(imageFile);
        params.put(ImagingConstants.PARAM_KEY_READ_THUMBNAILS, Boolean.valueOf(!ignoreImageData));

        final JpegPhotoshopMetadata metadata = new JpegImageParser().getPhotoshopMetadata(
                byteSource, params);
        assertNotNull(metadata);

        final File noIptcFile = removeIptc(byteSource);

        final JpegPhotoshopMetadata outMetadata = new JpegImageParser().getPhotoshopMetadata(
                new ByteSourceFile(noIptcFile), params);

        // FIXME should either be null or empty
        assertTrue(outMetadata == null
                || outMetadata.getItems().size() == 0);
    }

    public File removeIptc(final ByteSource byteSource) throws Exception {
        final File noIptcFile = createTempFile(imageFile.getName() + ".iptc.remove.", ".jpg");

        try (OutputStream os = new BufferedOutputStream(new FileOutputStream(noIptcFile))) {
            new JpegIptcRewriter().removeIPTC(byteSource, os);
        }
        return noIptcFile;
    }

    @Test
    public void testInsert() throws Exception {
        final ByteSource byteSource = new ByteSourceFile(imageFile);

        final Map<String, Object> params = new HashMap<>();
        final boolean ignoreImageData = isPhilHarveyTestImage(imageFile);
        params.put(ImagingConstants.PARAM_KEY_READ_THUMBNAILS, Boolean.valueOf(!ignoreImageData));

        final JpegPhotoshopMetadata metadata = new JpegImageParser().getPhotoshopMetadata(
                byteSource, params);
        assertNotNull(metadata);

        final File noIptcFile = removeIptc(byteSource);

        final List<IptcBlock> newBlocks = new ArrayList<>();
        final List<IptcRecord> newRecords = new ArrayList<>();

        newRecords.add(new IptcRecord(IptcTypes.CITY, "Albany, NY"));
        newRecords.add(new IptcRecord(IptcTypes.CREDIT,
                "William Sorensen"));

        final PhotoshopApp13Data newData = new PhotoshopApp13Data(newRecords,
                newBlocks);

        final File updated = createTempFile(imageFile.getName()
                + ".iptc.insert.", ".jpg");
        try (FileOutputStream fos = new FileOutputStream(updated);
                OutputStream os = new BufferedOutputStream(fos)) {
            new JpegIptcRewriter().writeIPTC(new ByteSourceFile(
                    noIptcFile), os, newData);
        }

        final ByteSource updateByteSource = new ByteSourceFile(updated);
        final JpegPhotoshopMetadata outMetadata = new JpegImageParser().getPhotoshopMetadata(
                updateByteSource, params);

        assertNotNull(outMetadata);
        assertTrue(outMetadata.getItems().size() == 2);
    }

    @Test
    public void testUpdate() throws Exception {
        final ByteSource byteSource = new ByteSourceFile(imageFile);

        final Map<String, Object> params = new HashMap<>();
        final boolean ignoreImageData = isPhilHarveyTestImage(imageFile);
        params.put(ImagingConstants.PARAM_KEY_READ_THUMBNAILS, Boolean.valueOf(!ignoreImageData));

        final JpegPhotoshopMetadata metadata = new JpegImageParser().getPhotoshopMetadata(byteSource, params);
        assertNotNull(metadata);

        final List<IptcBlock> newBlocks = metadata.photoshopApp13Data.getNonIptcBlocks();
        final List<IptcRecord> newRecords = new ArrayList<>();

        newRecords.add(new IptcRecord(IptcTypes.CITY, "Albany, NY"));
        newRecords.add(new IptcRecord(IptcTypes.CREDIT,
                "William Sorensen"));

        final PhotoshopApp13Data newData = new PhotoshopApp13Data(newRecords,
                newBlocks);

        final File updated = writeIptc(byteSource, newData);

        final ByteSource updateByteSource = new ByteSourceFile(updated);
        final JpegPhotoshopMetadata outMetadata = new JpegImageParser().getPhotoshopMetadata(
                updateByteSource, params);

        assertNotNull(outMetadata);
        assertTrue(outMetadata.getItems().size() == 2);
    }

    public File writeIptc(final ByteSource byteSource, final PhotoshopApp13Data newData) throws IOException, ImageReadException, ImageWriteException {
        final File updated = createTempFile(imageFile.getName()
                + ".iptc.update.", ".jpg");
        try (FileOutputStream fos = new FileOutputStream(updated);
                OutputStream os = new BufferedOutputStream(fos)) {
            new JpegIptcRewriter().writeIPTC(byteSource, os, newData);
        }
        return updated;
    }

    @Test
    public void testNoChangeUpdate() throws Exception {
        final ByteSource byteSource = new ByteSourceFile(imageFile);

        final Map<String, Object> params = new HashMap<>();
        final boolean ignoreImageData = isPhilHarveyTestImage(imageFile);
        params.put(ImagingConstants.PARAM_KEY_READ_THUMBNAILS, Boolean.valueOf(!ignoreImageData));

        final JpegPhotoshopMetadata metadata = new JpegImageParser().getPhotoshopMetadata(byteSource, params);
        assertNotNull(metadata);

        final List<IptcBlock> newBlocks = metadata.photoshopApp13Data.getNonIptcBlocks();
        final List<IptcRecord> oldRecords = metadata.photoshopApp13Data.getRecords();
        final List<IptcRecord> newRecords = new ArrayList<>();
        for (final IptcRecord record : oldRecords) {
            if (record.iptcType != IptcTypes.CITY
                    && record.iptcType != IptcTypes.CREDIT) {
                newRecords.add(record);
            }
        }

        newRecords.add(new IptcRecord(IptcTypes.CITY, "Albany, NY"));
        newRecords.add(new IptcRecord(IptcTypes.CREDIT, "William Sorensen"));

        final PhotoshopApp13Data newData = new PhotoshopApp13Data(newRecords, newBlocks);

        final File updated = writeIptc(byteSource, newData);

        final ByteSource updateByteSource = new ByteSourceFile(updated);
        final JpegPhotoshopMetadata outMetadata = new JpegImageParser().getPhotoshopMetadata(updateByteSource, params);

        assertNotNull(outMetadata);
        assertTrue(outMetadata.getItems().size() == newRecords.size());
    }

}
