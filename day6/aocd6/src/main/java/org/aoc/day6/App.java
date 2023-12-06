package org.aoc.day6;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;

/**
 * Hello world!
 *
 */
public class App 
{
    public static String[] getInput() {
        try {
            var input = Files.readString(Paths.get(App.class.getClassLoader().getResource("input.txt").toURI()));
            return input.split("\n");
        } catch (IOException e) {
            e.printStackTrace();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
        return new String[]{};
    }

    public static long[] waysToWin(long time, long dist) {
        long first = 0;
        long last = 0;
        for (long i = 0; i < time; ++i) {
                var velocity = i;
                var distance = (time - i) * velocity;
                if (distance > dist) {
                    first = i;
                    break;
                }
            };

        for (long i = time; i > 0; i--) {
                long velocity = i;
                long distance = (time - i) * velocity;
                if (distance > dist) {
                    last = i;
                    break;
                }
            };
        return  new long[]{first, last};
    }


    public static long[] getLongArray(String line) {
        return Arrays.asList(line.replaceAll("[^-?0-9]+", " ")
            .trim()
            .split(" "))
            .stream()
            .mapToLong(Long::parseLong)
            .toArray();
    }

    public static long combineLongArray(long[] arr) {
        return Long.parseLong(Arrays.stream(arr)
        .mapToObj(Long::toString)
        .reduce((i, j) -> i.concat("").concat(j))
        .get());
    }

    
    public static void main( String[] args )
    {
        var input = getInput();
        var time = getLongArray(input[0]);
        var records = getLongArray(input[1]);
        var part2time = combineLongArray(time);
        var part2records = combineLongArray(records);
        System.out.format("part2time, records: %d, %d\n", part2time, part2records);
        List<Long> numWaysToWin = new ArrayList<>();
        for (int i = 0; i< time.length; ++i) {
            var waysToWin = waysToWin(time[i], records[i]);
            numWaysToWin.add(waysToWin[1] - waysToWin[0] + 1);
        }
        var part1 = numWaysToWin
        .stream()
        .reduce(1L, (acc, v) -> acc * v)
        .intValue();
        System.out.format("part1: %d\n", part1);

        var p = waysToWin(part2time, part2records);
        var part2 = p[1] - p[0] + 1;
        System.out.format("part2: %d\n", part2);
    }
}
