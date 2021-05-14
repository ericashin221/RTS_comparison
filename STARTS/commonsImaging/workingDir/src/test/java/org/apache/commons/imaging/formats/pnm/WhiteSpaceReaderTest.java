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
package org.apache.commons.imaging.formats.pnm;

import org.junit.Test;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Arrays;

import static org.junit.Assert.assertEquals;

public class WhiteSpaceReaderTest{

  @Test
  public void testReadLineReturningNonEmptyString() throws IOException {
      byte[] byteArray = new byte[6];
      byteArray[4] = (byte)13;
      ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(byteArray);
      WhiteSpaceReader whiteSpaceReader = new WhiteSpaceReader(byteArrayInputStream);

      assertEquals(6, byteArrayInputStream.available());
      assertEquals("[0, 0, 0, 0]", Arrays.toString( whiteSpaceReader.readLine().getBytes() ) );
  }

}