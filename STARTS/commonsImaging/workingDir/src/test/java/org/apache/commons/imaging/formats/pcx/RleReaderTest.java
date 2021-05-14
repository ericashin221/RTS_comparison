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
package org.apache.commons.imaging.formats.pcx;

import org.junit.Test;

import java.io.ByteArrayInputStream;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

public class RleReaderTest{

    @Test
    public void testReadWithNonNull() {
        RleReader rleReader = new RleReader(false);
        byte[] byteArray = new byte[1];
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(byteArray, (byte) (-64), (byte) (-64));

        try {
            rleReader.read(byteArrayInputStream, byteArray);
            fail("Expecting exception: Exception");
        } catch(Exception e) {
            assertEquals("Premature end of file reading image data",e.getMessage());
            assertEquals(RleReader.class.getName(), e.getStackTrace()[0].getClassName());
        }
    }

}