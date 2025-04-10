/*
 * Copyright (C) 2025 sysource_xyz
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

 package mobile.funkin.backend.utils;

 /**
  * A storage class for mobile (internal assets only).
  * Adapted to run without external storage access or permissions.
  * @author sysource_xyz
  */
 class StorageUtil
 {
	 /**
	  * Always returns the internal assets directory path.
	  * This path is used for read-only assets bundled inside the .apk or .ipa file.
	  */
	 public static function getStorageDirectory():String
	 {
		 return "assets/"; // Internal path for bundled assets (read-only).
	 }
 
	 /**
	  * No-op for mobile builds since we no longer use external storage or request permissions.
	  */
	 public static function requestPermissions():Void
	 {
		 // Do nothing. Permissions are not needed when using internal assets only.
	 }
 } 