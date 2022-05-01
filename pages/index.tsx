import type { GetStaticProps } from "next";
import { useState } from "react";

type Props = {
  props: User[];
};

type User = {
  email: string;
};

const Home = ({ props }: Props) => {
  const [email, setEmail] = useState<string>("");
  const [emailList, setEmailList] = useState<User[]>(props);

  const onClick = async () => {
    const obj = {
      email,
    };
    const baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
    const url = `${baseUrl}/api/users`;
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(obj)
    });
    const result = await res.json();
    const arr = emailList;
    arr[emailList.length] = result;
    setEmailList(arr);
  };

  return (
    <div>
      <input
        type="text"
        onChange={(e) => setEmail(e.target.value)}
        value={email}
      />
      <button onClick={onClick}>登録</button>

      <ul>
        {emailList.map((user, i) => (
          <li key={i}>{user.email}</li>
        ))}
      </ul>
    </div>
  );
};

export default Home;

export const getStaticProps: GetStaticProps = async () => {
  const baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
  const url = `${baseUrl}/api/users`;
  const res = await fetch(url);
  const users = await res.json();

  return {
    props: {
      props: users,
    },
  };
};
