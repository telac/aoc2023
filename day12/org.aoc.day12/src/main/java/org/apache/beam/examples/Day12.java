
package org.apache.beam.examples;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.options.Validation.Required;
import org.apache.beam.sdk.transforms.Count;
import org.apache.beam.sdk.transforms.DoFn;
import org.apache.beam.sdk.transforms.InferableFunction;
import org.apache.beam.sdk.transforms.ParDo;
import org.apache.beam.sdk.transforms.SerializableFunction;
import org.apache.beam.sdk.transforms.SimpleFunction;
import org.apache.beam.sdk.transforms.ToString;
import org.apache.beam.sdk.transforms.DoFn.Element;
import org.apache.beam.sdk.values.KV;
import org.paukov.combinatorics3.Generator;
import org.paukov.combinatorics3.PermutationGenerator.TreatDuplicatesAs;

public class Day12 {


  public interface AocOptions extends PipelineOptions {

    /**
     * By default, this example reads from a public dataset containing the text of King Lear. Set
     * this option to choose a different input file or glob.
     */
    @Description("Path of the file to read from")
    @Default.String("test_case.txt")
    String getInputFile();

    void setInputFile(String value);

    /** Set this required option to specify where to write the output. */
    @Description("Path of the file to write to")
    @Default.String("counts")
    String getOutput();

    void setOutput(String value);
  }


  public record RowInfoContainer(int numBrokenSprings, int numGoodSprings, List<Integer> indexesToReplace){

  } 
  public static class GetValidPermutations extends DoFn<String, String> {

    public static RowInfoContainer getRowInfo(String record) {
      List<Integer> indexesToReplace = new ArrayList<>();
      int numBrokenSprings = 0;
      int numGoodSprings = 0;

      for (int i = 0; i < record.length(); i++) {
        switch (record.charAt(i)) {
          case '?' -> indexesToReplace.add(i);
          case '#' -> numBrokenSprings++;
          case '.' -> numGoodSprings++;
      }
    }


      return new RowInfoContainer(numBrokenSprings, numGoodSprings, indexesToReplace);
    }
    static List<Character> toCharacterList(final String in) {
        return in.chars().mapToObj(s -> ((char) s)).collect(Collectors.toList());
    }

    static String collToString(Collection<Character> collection) {
    return collection.stream().map(s -> s.toString()).collect(Collectors.joining());
}

    static boolean isValid(String perm, List<Integer> springList) {
      var currentSprings = 0;
      var matches = 0;
      for (var c : perm.toCharArray()) {
        if (c == '.') {
          var compMatches = springList.get(matches);
          if (currentSprings == compMatches) {
            if (currentSprings > compMatches) {
              return false;
            }
            matches++;
            if (matches == springList.size()) {
              return true;
            }
          }
          currentSprings = 0;
        }
        if (c == '#') {
          currentSprings++;

        } 
      }
      // if we got to the end without returning from inbetween the string
      var compMatches = springList.get(matches);
      return ((currentSprings == compMatches) && matches == springList.size() -1);
    }
    @ProcessElement
    public void processElement(@Element String input, OutputReceiver<String> out) {
      var row = input.split(" ");
      var record = row[0];
      var brokenSprings = List.of(row[1].split(","))
                .stream()
                .mapToInt(Integer::parseInt)
                .boxed()
                .collect(Collectors.toList());

      var numBrokenSprings = brokenSprings
                .stream()
                .collect(Collectors.summingInt(Integer::intValue));

      var rowInfo = getRowInfo(record);
      var brokenSpringsToAdd = numBrokenSprings - rowInfo.numBrokenSprings;
      var goodSpringsToAdd = record.length() - numBrokenSprings - rowInfo.numGoodSprings;
      System.out.println("row :" + record + "brokenSpringsToAdd: " + brokenSpringsToAdd + " goodSpringsToAdd " + goodSpringsToAdd);
      var stringToAdd = (".".repeat(goodSpringsToAdd) + "#".repeat(brokenSpringsToAdd));
      var characters = toCharacterList(stringToAdd);

      List<String> perms = Generator.permutation(characters)
      .simple(TreatDuplicatesAs.DIFFERENT)
      .stream()
      .map(GetValidPermutations::collToString)
      .collect(Collectors.toList());

      for (var perm : perms) {
        char[] origArray = record.toCharArray();
        for (int i = 0; i < (perm.length()); i++) {
          var idx = rowInfo.indexesToReplace.get(i);
          origArray[idx] = perm.charAt(i);
        }
        var res = new String(origArray);
        if (isValid(res, brokenSprings)) {
          out.output(record + " --> " + res);
        } 
      }
    }
  }
  static void runDay11(AocOptions options) {
    Pipeline p = Pipeline.create(options);


    p.apply("ReadLines", TextIO.read().from(options.getInputFile()))
        .apply(ParDo.of(new GetValidPermutations()))
        .apply(Count.globally())
        .apply(ToString.elements())
        .apply("writeOutput", TextIO.write().to(options.getOutput()));
    p.run().waitUntilFinish();
  }

  public static void main(String[] args) {
    AocOptions options =
        PipelineOptionsFactory.fromArgs(args).withValidation().as(AocOptions.class);

    runDay11(options);
  }
}
