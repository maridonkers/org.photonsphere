+++
author = "Mari Donkers"
title = "Serializing any-size objects to a random access file"
date = "2011-06-29"
description = "This article will delve into the details involved in serializing and deserializing arbitrarily sized objects to- and from a byte array. The contents of the byte array are stored in a random access file. An index file is kept to allow for objects of varying size."
featured = true
tags = [
    "Computer",
    "Software",
    "Java",
    "IO"
]
categories = [
    "development",
    "java",
]
series = ["Development", "Java"]
aliases = ["2011-06-29-serializing-any-size-objects-to-a-random-access-file"]
thumbnail = "/images/java.svg"
+++

This article will delve into the details involved in serializing and deserializing arbitrarily sized objects to- and from a byte array. The contents of the byte array are stored in a random access file. An index file is kept to allow for objects of varying size.

# Serializable objects

Any object that is an instance of a class that implements the `Serializable` interface, can be serialized and deserialized. Such a class is e.g. coded as follows:

``` java
import java.io.Serializable;
public class Entry implements Serializable {
 ...
}
```

# Object serialization to- and deserialization from a byte array

To achieve object serialization the `ObjectOutputStream` class is used, and for object deserialization the `ObjectInputStream` class. To write a serialized object to an array of bytes the `ByteArrayOutputStream` class is used, and to read a serialized object from an array of bytes the `ByteArrayInputStream` class is used.

An example of such serialization and deserialization code is listed below:

``` java
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.Date;

public class Entry implements Serializable {

    private Date timestamp = new Date();
    private String username;
    private String message;

    public Entry(String username, String message) {
        this.username = username;
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public Date getTimestamp() {
        return timestamp;
    }

    public String getUsername() {
        return username;
    }

    public static byte[] serialize(Entry entry)
            throws IOException {

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(baos);
        oos.writeObject(entry);
        oos.flush();

        return baos.toByteArray();
    }

    public static Entry deserialize(byte[] byteArray)
            throws IOException, ClassNotFoundException {

        ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(byteArray));
        Entry entry = (Entry) ois.readObject();

        return entry;
    }
}
```

# Append to- and read from random access file

Now we have the serialized object in a byte array we can store it in a random access file and read it back later. Java's highly speed optimized new I/O library (`nio`) is used for this. Because the length of the serialized object can vary, an index file is kept, which allows for arbitrarily sized serialized objects to be stored.

The append to- and read from file code is listed below:

``` java
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;

public class EntryFile {

    public static final String DATA_EXT = ".dat";
    public static final String INDEX_EXT = ".idx";
    public static final int INDEX_SIZE = Long.SIZE / 8;
    private FileChannel fci;
    private FileChannel fcd;

    public EntryFile(String fileName)
            throws FileNotFoundException, IOException {

        fci = new RandomAccessFile(fileName + EntryFile.INDEX_EXT, "rw").getChannel();
        fci.force(true);
        fcd = new RandomAccessFile(fileName + EntryFile.DATA_EXT, "rw").getChannel();
        fcd.force(true);
    }

    public void close()
            throws IOException {

        fcd.close();
        fci.close();
    }

    public long appendEntry(Entry entry)
            throws IOException {

        // Calculate the data index for append to data
        // file and append its value to the index file.
        long byteOffset = fci.size();
        long index = byteOffset / (long) EntryFile.INDEX_SIZE;
        long dataOffset = (int) fcd.size();
        ByteBuffer bb = ByteBuffer.allocate(EntryFile.INDEX_SIZE);
        bb.putLong(dataOffset);
        bb.flip();
        fci.position(byteOffset);
        fci.write(bb);

        // Append serialized object data to the data file.
        byte[] se = Entry.serialize(entry);
        fcd.position(dataOffset);
        fcd.write(ByteBuffer.wrap(se));

        return index;
    }

    public Entry readEntry(long index)
            throws IOException, ClassNotFoundException {

        // Get the data index and -length from the index file.
        long byteOffset = index * (long) EntryFile.INDEX_SIZE;
        ByteBuffer bbi = ByteBuffer.allocate(EntryFile.INDEX_SIZE);
        fci.position(byteOffset);
        if (fci.read(bbi) == -1) {
            throw new IndexOutOfBoundsException("Specified index is out of range");
        }
        bbi.flip();
        long dataOffset = bbi.getLong();
        bbi.rewind();
        long dataOffsetNext;
        if (fci.read(bbi) == -1) {
            dataOffsetNext = fcd.size();
        } else {
            bbi.flip();
            dataOffsetNext = bbi.getLong();
        }
        int dataSize = (int) (dataOffsetNext - dataOffset);

        // Get the serialized object data in a byte array.
        byte[] se = new byte[dataSize];
        fcd.position(dataOffset);
        fcd.read(ByteBuffer.wrap(se));

        // Deserialize the byte array into an instantiated object.
        return Entry.deserialize(se);
    }
}
```

# Use of the code

The code above can be used as follows:

``` java
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Main {

    public static void main(String args[]) {

        EntryFile entryFile = null;
        try {
            entryFile = new EntryFile("entries");
            for (int i = 0; i < 100; i++) {
                Entry entry = new Entry("name[" + i + "]", "message[" + i + "]");
                entryFile.appendEntry(entry);
            }
            for (int i = 99; i >= 0; i--) {
                Entry entry = entryFile.readEntry(i);
                System.out.println("Entry["+i+"]");
                System.out.println("\\ttimestamp=" + entry.getTimestamp().toString());
                System.out.println("\\tusername=" + entry.getUsername());
                System.out.println("\\tmessage=" + entry.getMessage());
            }
            entryFile.close();
        } catch (FileNotFoundException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
```

This code creates, serializes and writes 100 objects to file and when done, reads back, deserializes and prints the 100 retrieved objects to standard output, in reverse order.

# Advantages of serializing via a byte array

Serializing objects via a byte array instead of directly to file allows for more control over the process. One can add extra information to each stored object, e.g. a length and a checksum. A length is useful when the index file gets corrupted and needs to be regenerated. A checksum can be used to verify the validity of the stored serialized object.

# References

[How to access your database from the development environment – Marco Ronchetti Università degli Studi di Trento](http://latemar.science.unitn.it/segue_userFiles/2014Mobile/Android6_2014.pptx.pdf)
